require "net/http"
require "json"

module Events
  module Sources
    # OpenHolidaysAPI — free, open source, no key required.
    # Docs: https://www.openholidaysapi.org/
    class OpenHolidays
      BASE_URL = "https://openholidaysapi.org"

      # ISO 3166-1 alpha-2 codes supported by OpenHolidaysAPI
      COUNTRIES = %w[AD AL AT AU BA BE BG BR BY CA CH CY CZ DE DK EE ES FI FR GB
                     GR HR HU IE IS IT LI LT LU LV ME MK MT NL NO PL PT RO RS SE
                     SI SK UA US VA XK].freeze

      def self.fetch(years:, countries: COUNTRIES)
        records = []

        countries.each do |country_code|
          years.each do |year|
            from = "#{year}-01-01"
            to   = "#{year}-12-31"
            holidays = fetch_holidays(country_code, from, to)
            holidays.each { |h| records << build_record(h, country_code) }
          rescue => e
            Rails.logger.warn "[Events::Sources::OpenHolidays] #{country_code}/#{year}: #{e.message}"
          end
        end

        records.compact
      end

      def self.fetch_holidays(country_code, from, to)
        uri = URI("#{BASE_URL}/PublicHolidays")
        uri.query = URI.encode_www_form(
          countryIsoCode:  country_code,
          validFrom:       from,
          validTo:         to,
          languageIsoCode: "EN"
        )
        response = Net::HTTP.get_response(uri)
        return [] unless response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      rescue => e
        Rails.logger.warn "[Events::Sources::OpenHolidays] fetch #{country_code}: #{e.message}"
        []
      end
      private_class_method :fetch_holidays

      def self.build_record(holiday, country_code)
        date = Date.parse(holiday["startDate"])
        name = holiday.dig("name", 0, "text") || holiday["id"]
        return nil if name.blank?

        name         = name.strip
        country_name = CountryUtils.country_name(country_code)
        slug         = "#{name.parameterize}-#{CountryUtils.country_slug_name(country_code)}-#{date.year}"
        timezone     = CountryUtils.primary_timezone(country_code)

        {
          title:         "#{name} (#{country_name})",
          slug:          slug,
          category:      "holidays",
          description:   "#{name} is a public holiday in #{country_name} on #{date.strftime("%B %-d, %Y")}.",
          starts_at:     CountryUtils.midnight_utc(country_code, date.year, date.month, date.day),
          timezone:      timezone,
          recurrence:    "annual",
          featured:      false,
          country_codes: [ country_code ],
          published:     true,
          source:        "openholidays",
          external_id:   "openholidays:#{country_code}:#{holiday["startDate"]}:#{name.parameterize}"
        }
      end
      private_class_method :build_record
    end
  end
end
