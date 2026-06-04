module Events
  module Sources
    # Converts NagerDate public holidays into Event records.
    # Fetches for the configured countries and the given year range.
    class NagerDate
      COUNTRIES = NagerDateClient::FALLBACK_COUNTRIES.map { |c| c["countryCode"] }.freeze

      def self.fetch(years:, countries: COUNTRIES)
        records = []

        countries.each do |country_code|
          years.each do |year|
            holidays = ::NagerDateClient.holidays_with_names(year: year, country_code: country_code)
            holidays.each do |h|
              records << build_record(h, country_code, year)
            end
          rescue => e
            Rails.logger.warn "[Events::Sources::NagerDate] #{country_code}/#{year}: #{e.message}"
          end
        end

        records.compact
      end

      def self.build_record(holiday, country_code, year)
        date         = Date.parse(holiday["date"])
        name         = holiday["name"].strip
        country_name = CountryUtils.country_name(country_code)
        slug         = "#{name.parameterize}-#{CountryUtils.country_slug_name(country_code)}-#{year}"
        types        = Array(holiday["types"])
        timezone     = CountryUtils.primary_timezone(country_code)

        {
          title:         "#{name} (#{country_name})",
          slug:          slug,
          category:      types.include?("Public") ? "holidays" : "cultural",
          description:   "#{name} is a public holiday in #{country_name} on #{date.strftime("%B %-d, %Y")}.",
          starts_at:     CountryUtils.midnight_utc(country_code, date.year, date.month, date.day),
          timezone:      timezone,
          recurrence:    "annual",
          featured:      false,
          country_codes: [ country_code ],
          published:     true,
          source:        "nagerdate",
          external_id:   "nagerdate:#{country_code}:#{holiday["date"]}:#{name.parameterize}"
        }
      end
      private_class_method :build_record
    end
  end
end
