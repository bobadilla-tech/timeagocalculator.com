module Events
  # Orchestrates event ingestion from all configured sources.
  #
  # Modes:
  #   :full    — loads historical + current + future years (big first load)
  #   :refresh — loads current year + next 2 years only
  #
  # Records are upserted by slug (idempotent). Past events are never deleted —
  # they serve as "how long since X" pages.
  class Ingestor
    FULL_YEARS_BEHIND    = 2
    FULL_YEARS_AHEAD     = 3
    REFRESH_YEARS_BEHIND = 0
    REFRESH_YEARS_AHEAD  = 2

    BATCH_SIZE = 200

    def self.run(mode: :refresh, fetch_images: true)
      new(mode: mode, fetch_images: fetch_images).run
    end

    def initialize(mode:, fetch_images:)
      @mode         = mode
      @fetch_images = fetch_images
      @current_year = Date.current.year
    end

    def run
      Rails.logger.info "[Events::Ingestor] Starting #{@mode} ingestion"
      start = Time.current

      records = collect_records
      Rails.logger.info "[Events::Ingestor] Collected #{records.size} raw records"

      records = deduplicate(records)
      Rails.logger.info "[Events::Ingestor] #{records.size} unique records after dedup"

      fetch_images!(records) if @fetch_images

      upserted = upsert_all(records)
      elapsed  = (Time.current - start).round(1)

      Rails.logger.info "[Events::Ingestor] Done — #{upserted} upserted in #{elapsed}s"
      { upserted: upserted, elapsed: elapsed }
    end

    private

    def years_range
      behind = @mode == :full ? FULL_YEARS_BEHIND : REFRESH_YEARS_BEHIND
      ahead  = @mode == :full ? FULL_YEARS_AHEAD  : REFRESH_YEARS_AHEAD
      (@current_year - behind)..(@current_year + ahead)
    end

    def years_array
      years_range.to_a
    end

    def collect_records
      records = []
      records.concat(Sources::Curated.fetch(
        years_ahead:  @mode == :full ? FULL_YEARS_AHEAD  : REFRESH_YEARS_AHEAD,
        years_behind: @mode == :full ? FULL_YEARS_BEHIND : REFRESH_YEARS_BEHIND
      ))
      records.concat(Sources::Leaders.fetch)
      records.concat(Sources::NagerDate.fetch(years: years_array))
      records.concat(Sources::OpenHolidays.fetch(years: years_array))
      records.concat(Sources::Calendarific.fetch(years: years_array))
      records
    end

    # Lower index = higher priority (wins dedup)
    SOURCE_PRIORITY = %w[curated calendarific nagerdate openholidays].freeze

    def deduplicate(records)
      by_slug   = {}
      by_ext_id = {}

      records.each do |rec|
        slug   = rec[:slug]
        ext_id = rec[:external_id]

        existing_by_ext = by_ext_id[ext_id]
        next if existing_by_ext && source_priority(existing_by_ext) <= source_priority(rec)

        existing = by_slug[slug]
        if existing.nil? || source_priority(existing) > source_priority(rec)
          by_slug[slug]     = rec
          by_ext_id[ext_id] = rec if ext_id
        end
      end

      by_slug.values
    end

    def source_priority(rec)
      SOURCE_PRIORITY.index(rec[:source].to_s) || 99
    end

    def fetch_images!(records)
      records.each do |rec|
        next if rec[:image_url].present?
        next unless rec[:wikipedia_title].present?

        url = Events::WikipediaImageFetcher.fetch(rec[:wikipedia_title])
        rec[:image_url] = url if url
      end
    end

    def upsert_all(records)
      return 0 if records.empty?

      now         = Time.current
      upsert_data = records.map do |rec|
        rec.except(:wikipedia_title).merge(created_at: now, updated_at: now)
      end

      count = 0
      upsert_data.each_slice(BATCH_SIZE) do |batch|
        result = Event.upsert_all(
          batch,
          unique_by:   :slug,
          update_only: %i[title description starts_at ends_at category
                          image_url country_codes featured recurrence
                          external_id published source timezone]
        )
        count += result.length
      end
      count
    end
  end
end
