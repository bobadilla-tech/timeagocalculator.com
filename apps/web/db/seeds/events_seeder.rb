class EventsSeeder < BaseSeeder
  def run
    load_json("events.json").each do |attrs|
      event = Event.find_or_initialize_by(slug: attrs["slug"])
      event.title       = attrs["title"]
      event.starts_at   = attrs["starts_at"]
      event.category    = attrs["category"]
      event.source      = attrs["source"]
      event.description = attrs["description"]
      event.body        = attrs["body"] if attrs["body"].present?
      event.save!
    end
    puts "[EventsSeeder] #{Event.count} events"
  end
end
