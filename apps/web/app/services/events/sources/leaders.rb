require "json"
require "time"

module Events
  module Sources
    class Leaders
      SEED_PATH = Rails.root.join("db/seeds/data/leaders.json")

      def self.fetch
        JSON.parse(File.read(SEED_PATH)).map do |entry|
          {
            title:         entry["name"],
            slug:          "#{entry["name"].parameterize}-#{entry["role"].parameterize}-#{entry["starts_at"][0..3]}",
            category:      "leaders",
            description:   entry["role"],
            body:          entry["party"],
            starts_at:     Time.parse(entry["starts_at"]),
            ends_at:       entry["ends_at"] ? Time.parse(entry["ends_at"]) : nil,
            recurrence:    "one_time",
            featured:      false,
            country_codes: entry["country_codes"],
            published:     true,
            source:        "leaders",
            external_id:   "leaders:#{entry["name"].parameterize}-#{entry["starts_at"]}"
          }
        end
      end
    end
  end
end
