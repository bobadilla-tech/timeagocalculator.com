class HolidaysSeeder < BaseSeeder
  def run
    load_json("holidays.json").each do |attrs|
      holiday = Holiday.find_or_initialize_by(slug: attrs["slug"])
      holiday.title       = attrs["title"]
      holiday.month       = attrs["month"]
      holiday.day         = attrs["day"]
      holiday.country     = attrs["country"] || "US"
      holiday.description = attrs["description"]
      holiday.save!
    end
    puts "[HolidaysSeeder] #{Holiday.count} holidays"
  end
end
