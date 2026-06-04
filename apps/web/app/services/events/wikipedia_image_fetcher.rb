require "net/http"
require "json"
require "uri"

module Events
  class WikipediaImageFetcher
    API_URL    = "https://en.wikipedia.org/w/api.php"
    THUMB_SIZE = 600

    # Returns image URL string or nil. Caches 30 days since images rarely change.
    def self.fetch(wikipedia_title)
      return nil if wikipedia_title.blank?

      cache_key = "wikipedia/image/#{wikipedia_title.parameterize}"
      Rails.cache.fetch(cache_key, expires_in: 30.days) do
        fetch_uncached(wikipedia_title)
      end
    rescue => e
      Rails.logger.warn "[WikipediaImageFetcher] #{wikipedia_title}: #{e.message}"
      nil
    end

    def self.fetch_uncached(wikipedia_title)
      uri = URI(API_URL)
      uri.query = URI.encode_www_form(
        action:      "query",
        titles:      wikipedia_title,
        prop:        "pageimages",
        format:      "json",
        pithumbsize: THUMB_SIZE,
        pilicense:   "any"
      )

      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data  = JSON.parse(response.body)
      pages = data.dig("query", "pages") || {}
      page  = pages.values.first
      page&.dig("thumbnail", "source")
    end
    private_class_method :fetch_uncached
  end
end
