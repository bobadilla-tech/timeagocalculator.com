namespace :events do
  desc "Full load: ingest events from all sources for historical + upcoming years"
  task ingest: :environment do
    result = Events::Ingestor.run(mode: :full, fetch_images: true)
    puts "Ingested #{result[:upserted]} events in #{result[:elapsed]}s"
  end

  desc "Refresh: ingest upcoming events only (current + next 2 years)"
  task refresh: :environment do
    result = Events::Ingestor.run(mode: :refresh, fetch_images: true)
    puts "Refreshed #{result[:upserted]} events in #{result[:elapsed]}s"
  end

  desc "Delete all API-sourced events (nagerdate/openholidays/calendarific) — run before re-ingesting after slug format changes"
  task clean_api_events: :environment do
    sources = %w[nagerdate openholidays calendarific]
    count   = Event.where(source: sources).count
    Event.where(source: sources).delete_all
    puts "Deleted #{count} API-sourced events."
  end

  desc "Seed leaders (US Presidents, UK PMs, UK Monarchs) from data/seeds/leaders.json"
  task seed_leaders: :environment do
    records = Events::Sources::Leaders.fetch
    now = Time.current
    data = records.map { |r| r.merge(created_at: now, updated_at: now) }
    count = 0
    data.each_slice(50) do |batch|
      result = Event.upsert_all(
        batch,
        unique_by:   :slug,
        update_only: %i[title description body starts_at ends_at category
                        country_codes recurrence published source external_id]
      )
      count += result.length
    end
    puts "Seeded #{count} leader records."
  end

  desc "Backfill Wikipedia images for events missing image_url"
  task backfill_images: :environment do
    events = Event.where(image_url: nil).where.not(source: nil)
    puts "Backfilling images for #{events.count} events..."

    events.find_each do |event|
      # Derive wikipedia_title from title as fallback (no stored field)
      wikipedia_title = event.title.gsub(/\s+\d{4}$/, "") # strip trailing year
      url = Events::WikipediaImageFetcher.fetch(wikipedia_title)
      if url
        event.update_columns(image_url: url, updated_at: Time.current)
        print "."
      else
        print "x"
      end
    end
    puts "\nDone."
  end
end
