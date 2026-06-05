class HomeController < ApplicationController
  def index
    @featured  = Event.published.featured.sorted_upcoming.first
    excluded   = [@featured&.id].compact

    @coming_up = Event.published.upcoming
                      .where.not(id: excluded)
                      .where.not(image_url: nil)
                      .sorted_upcoming.limit(6)
    @coming_up = Event.published.upcoming
                      .where.not(id: excluded)
                      .sorted_upcoming.limit(6) if @coming_up.empty?
    excluded  += @coming_up.map(&:id)

    @highlights = Event.published.upcoming
                       .where(recurrence: "annual", source: "curated")
                       .where.not(id: excluded)
                       .where.not(image_url: nil)
                       .sorted_upcoming.limit(4)

    set_meta_tags(
      title: "Time Ago Calculator — Countdowns & Date Tools",
      description: "Calculate how long ago any date was, count down to upcoming events, and explore date tools.",
      canonical: root_url
    )
  end
end
