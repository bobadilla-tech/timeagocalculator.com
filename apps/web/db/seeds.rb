events_path   = Rails.root.join("../../data/seeds/historical_events.json")
holidays_path = Rails.root.join("../../data/seeds/holidays.json")

JSON.parse(File.read(events_path)).each do |attrs|
  event = Event.find_or_initialize_by(slug: attrs["slug"])
  event.title       = attrs["title"]
  event.starts_at   = attrs["starts_at"]
  event.category    = attrs["category"]
  event.source      = attrs["source"]
  event.description = attrs["description"]
  event.body        = attrs["body"] if attrs["body"].present?
  event.save!
end

JSON.parse(File.read(holidays_path)).each do |attrs|
  Holiday.find_or_create_by(slug: attrs["slug"]) do |h|
    h.title       = attrs["title"]
    h.month       = attrs["month"]
    h.day         = attrs["day"]
    h.country     = attrs["country"] || "US"
    h.description = attrs["description"]
  end
end

puts "Seeded #{Event.count} events and #{Holiday.count} holidays"
