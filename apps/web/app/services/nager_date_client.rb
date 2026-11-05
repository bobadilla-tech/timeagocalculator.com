require "net/http"
require "json"

class NagerDateClient
  BASE_URL = "https://date.nager.at/api/v3"

  FALLBACK_COUNTRIES = [
    { "countryCode" => "US", "name" => "United States" },
    { "countryCode" => "GB", "name" => "United Kingdom" },
    { "countryCode" => "CA", "name" => "Canada" },
    { "countryCode" => "AU", "name" => "Australia" },
    { "countryCode" => "DE", "name" => "Germany" },
    { "countryCode" => "FR", "name" => "France" },
    { "countryCode" => "ES", "name" => "Spain" },
    { "countryCode" => "IT", "name" => "Italy" },
    { "countryCode" => "NL", "name" => "Netherlands" },
    { "countryCode" => "JP", "name" => "Japan" },
    { "countryCode" => "BR", "name" => "Brazil" },
    { "countryCode" => "MX", "name" => "Mexico" },
    { "countryCode" => "IN", "name" => "India" },
    { "countryCode" => "NZ", "name" => "New Zealand" },
    { "countryCode" => "ZA", "name" => "South Africa" },
    { "countryCode" => "AR", "name" => "Argentina" },
    { "countryCode" => "SE", "name" => "Sweden" },
    { "countryCode" => "NO", "name" => "Norway" },
    { "countryCode" => "PL", "name" => "Poland" },
    { "countryCode" => "PT", "name" => "Portugal" },
    { "countryCode" => "PE", "name" => "Peru" },
    { "countryCode" => "CL", "name" => "Chile" },
    { "countryCode" => "CO", "name" => "Colombia" }
  ].freeze

  def self.available_countries
    Rails.cache.fetch("nagerdate/countries", expires_in: 7.days) do
      uri = URI("#{BASE_URL}/AvailableCountries")
      JSON.parse(Net::HTTP.get(uri))
    end
  rescue => e
    Rails.logger.warn "[NagerDateClient] countries error: #{e.message}"
    FALLBACK_COUNTRIES
  end

  def self.country_code_for_slug(slug)
    available_countries.find { |c| c["name"].parameterize == slug }&.dig("countryCode")
  end

  # Returns raw holiday hashes: [{ "date" => "2026-01-01", "name" => "New Year's Day", ... }]
  def self.holidays_with_names(year:, country_code:)
    Rails.cache.fetch("nagerdate/holidays_full/#{year}/#{country_code}", expires_in: 24.hours) do
      uri    = URI("#{BASE_URL}/PublicHolidays/#{year}/#{country_code}")
      result = JSON.parse(Net::HTTP.get(uri))
      result.is_a?(Array) ? result : []
    end
  rescue => e
    Rails.logger.warn "[NagerDateClient] holidays_with_names error #{year}/#{country_code}: #{e.message}"
    []
  end

  # Returns array of Date objects
  def self.holidays(year:, country_code:)
    holidays_with_names(year:, country_code:).map { |h| Date.parse(h["date"]) }
  rescue => e
    Rails.logger.warn "[NagerDateClient] holidays error #{year}/#{country_code}: #{e.message}"
    []
  end
end
