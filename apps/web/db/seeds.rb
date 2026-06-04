require_relative "seeds/base_seeder"
require_relative "seeds/events_seeder"
require_relative "seeds/holidays_seeder"

EventsSeeder.run
HolidaysSeeder.run
