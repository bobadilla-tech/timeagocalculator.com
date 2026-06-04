require "tzinfo"

module Events
  module CountryUtils
    # Countries with multiple IANA timezones — map to capital/primary zone
    MULTI_TZ_PRIMARIES = {
      "US" => "America/New_York",
      "CA" => "America/Toronto",
      "AU" => "Australia/Sydney",
      "BR" => "America/Sao_Paulo",
      "MX" => "America/Mexico_City",
      "RU" => "Europe/Moscow",
      "ES" => "Europe/Madrid",
      "PT" => "Europe/Lisbon",
      "FR" => "Europe/Paris",
      "NL" => "Europe/Amsterdam",
      "NO" => "Europe/Oslo",
      "ID" => "Asia/Jakarta",
      "CN" => "Asia/Shanghai",
      "AR" => "America/Argentina/Buenos_Aires",
      "CL" => "America/Santiago",
      "CO" => "America/Bogota",
      "PE" => "America/Lima",
      "GB" => "Europe/London",
      "DE" => "Europe/Berlin",
      "IT" => "Europe/Rome",
      "PL" => "Europe/Warsaw",
      "SE" => "Europe/Stockholm",
      "UA" => "Europe/Kyiv",
      "BY" => "Europe/Minsk",
      "RS" => "Europe/Belgrade",
      "GL" => "America/Godthab",
      "KZ" => "Asia/Almaty",
      "MN" => "Asia/Ulaanbaatar",
    }.freeze

    # IANA doesn't cover some territories — provide names manually
    IANA_FALLBACK_NAMES = {
      "XK" => "Kosovo",
      "VA" => "Vatican City",
      "EH" => "Western Sahara",
      "BL" => "Saint Barthélemy",
      "MF" => "Saint Martin",
      "SX" => "Sint Maarten",
      "CW" => "Curaçao",
      "BQ" => "Bonaire",
      "SS" => "South Sudan",
    }.freeze

    IANA_FALLBACK_TIMEZONES = {
      "XK" => "Europe/Belgrade",
      "VA" => "Europe/Rome",
      "EH" => "Africa/El_Aaiun",
      "BL" => "America/St_Barthelemy",
      "MF" => "America/Marigot",
      "SX" => "America/Lower_Princes",
      "CW" => "America/Curacao",
      "BQ" => "America/Kralendijk",
      "SS" => "Africa/Juba",
    }.freeze

    def self.country_name(code)
      return IANA_FALLBACK_NAMES[code] if IANA_FALLBACK_NAMES.key?(code)
      TZInfo::Country.get(code).name
    rescue TZInfo::InvalidCountryCode
      code
    end

    # URL/slug-safe parameterized country name: "NZ" → "new-zealand"
    def self.country_slug_name(code)
      country_name(code).parameterize
    end

    # Primary IANA timezone identifier for a country code
    def self.primary_timezone(code)
      return MULTI_TZ_PRIMARIES[code] if MULTI_TZ_PRIMARIES.key?(code)
      return IANA_FALLBACK_TIMEZONES[code] if IANA_FALLBACK_TIMEZONES.key?(code)

      zones = TZInfo::Country.get(code).zone_identifiers
      zones.first
    rescue TZInfo::InvalidCountryCode
      "UTC"
    end

    # Build a midnight-local UTC Time for a given country + date
    def self.midnight_utc(country_code, year, month, day)
      tz_name = primary_timezone(country_code)
      Time.use_zone(tz_name) { Time.zone.local(year, month, day, 0, 0, 0) }
    rescue => e
      Rails.logger.warn "[CountryUtils] timezone error #{country_code}: #{e.message}"
      Time.utc(year, month, day, 0, 0, 0)
    end
  end
end
