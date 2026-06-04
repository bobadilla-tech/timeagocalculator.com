require "json"

module Events
  module Sources
    # Generates Event records from data/seeds/curated_events.json.
    # Annual events get instances created for years: (current-1)..(current+3).
    # Quadrennial events get one instance for the nearest relevant year.
    class Curated
      SEED_PATH    = Rails.root.join("../../data/seeds/curated_events.json")
      YEARS_AHEAD  = 3
      YEARS_BEHIND = 1

      def self.fetch(years_ahead: YEARS_AHEAD, years_behind: YEARS_BEHIND)
        templates = JSON.parse(File.read(SEED_PATH))
        current_year = Date.current.year
        records = []

        templates.each do |tmpl|
          case tmpl["recurrence"]
          when "annual"
            (current_year - years_behind).upto(current_year + years_ahead) do |year|
              records << build_record(tmpl, year)
            end
          when "quadrennial"
            # Find the next quadrennial year from a base
            base_year = tmpl["base_year"] || current_year
            year = base_year
            year += 4 while year < current_year - 1
            records << build_record(tmpl, year)
            records << build_record(tmpl, year + 4)
          else
            records << build_record(tmpl, current_year)
          end
        end

        records.compact
      end

      def self.build_record(tmpl, year)
        month        = tmpl["typical_month"]
        day          = tmpl["typical_day"]
        country_codes = tmpl["country_codes"] || []

        # Clamp day to valid range for the month/year
        max_day = Date.new(year, month, -1).day
        day = [ day, max_day ].min

        # Use country timezone for single-country events; noon UTC for global events
        timezone, starts_at = if country_codes.size == 1
          tz = CountryUtils.primary_timezone(country_codes.first)
          [ tz, CountryUtils.midnight_utc(country_codes.first, year, month, day) ]
        else
          [ nil, Time.utc(year, month, day, 12, 0, 0) ]
        end

        slug = "#{tmpl["slug_base"]}-#{year}"

        {
          title:           "#{tmpl["title"]} #{year}",
          slug:            slug,
          category:        tmpl["category"],
          description:     tmpl["description"],
          starts_at:       starts_at,
          timezone:        timezone,
          recurrence:      tmpl["recurrence"] == "annual" ? "annual" : "one_time",
          featured:        tmpl["featured"] || false,
          country_codes:   country_codes,
          published:       true,
          source:          "curated",
          external_id:     "curated:#{slug}",
          wikipedia_title: tmpl["wikipedia_title"]
        }
      end
      private_class_method :build_record
    end
  end
end
