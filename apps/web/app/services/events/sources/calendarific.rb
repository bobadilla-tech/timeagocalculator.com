require "net/http"
require "json"

module Events
  module Sources
    # Calendarific API — free tier: 1000 req/month.
    # Requires CALENDARIFIC_API_KEY env var. Skipped silently if key absent.
    # Docs: https://calendarific.com/api-documentation
    class Calendarific
      BASE_URL = "https://calendarific.com/api/v2"

      COUNTRIES = %w[US GB CA AU DE FR ES IT JP BR IN MX NZ ZA AR SE NO PL].freeze

      def self.fetch(years:, countries: COUNTRIES)
        api_key = ENV["CALENDARIFIC_API_KEY"]
        unless api_key.present?
          Rails.logger.info "[Events::Sources::Calendarific] No API key — skipping"
          return []
        end

        records = []
        countries.each do |country_code|
          years.each do |year|
            holidays = fetch_holidays(api_key, country_code, year)
            holidays.each { |h| records << build_record(h, country_code) }
          rescue => e
            Rails.logger.warn "[Events::Sources::Calendarific] #{country_code}/#{year}: #{e.message}"
          end
        end
        records.compact
      end

      def self.fetch_holidays(api_key, country_code, year)
        uri = URI("#{BASE_URL}/holidays")
        uri.query = URI.encode_www_form(
          api_key: api_key,
          country: country_code,
          year:    year,
          type:    "national"
        )
        response = Net::HTTP.get_response(uri)
        return [] unless response.is_a?(Net::HTTPSuccess)

        body = JSON.parse(response.body)
        body.dig("response", "holidays") || []
      rescue => e
        Rails.logger.warn "[Events::Sources::Calendarific] HTTP #{country_code}/#{year}: #{e.message}"
        []
      end
      private_class_method :fetch_holidays

      def self.build_record(holiday, country_code)
        date_hash    = holiday["date"]["iso"]
        date         = Date.parse(date_hash)
        name         = holiday["name"].strip
        country_name = CountryUtils.country_name(country_code)
        slug         = "#{name.parameterize}-#{CountryUtils.country_slug_name(country_code)}-#{date.year}"
        type         = holiday["type"]&.first&.downcase || "holidays"
        timezone     = CountryUtils.primary_timezone(country_code)

        {
          title:         "#{name} (#{country_name})",
          slug:          slug,
          category:      type == "national" ? "holidays" : "cultural",
          description:   holiday["description"].presence ||
                           "#{name} is observed in #{country_name} on #{date.strftime("%B %-d, %Y")}.",
          starts_at:     CountryUtils.midnight_utc(country_code, date.year, date.month, date.day),
          timezone:      timezone,
          recurrence:    "annual",
          featured:      false,
          country_codes: [ country_code ],
          published:     true,
          source:        "calendarific",
          external_id:   "calendarific:#{country_code}:#{date_hash}:#{name.parameterize}"
        }
      end
      private_class_method :build_record
    end
  end
end
