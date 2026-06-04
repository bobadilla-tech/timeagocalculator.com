class EventsController < ApplicationController
  include SeoMetaTaggable

  def show
    @event  = Event.published.find_by!(slug: params[:slug])
    @result = @event.time_ago

    set_meta_tags(
      title: "How Long Ago Was #{@event.title}?",
      description: "#{@event.title} was #{@result&.human || "a historical event"}. Full breakdown in years, months and days.",
      canonical: how_long_ago_url(@event.slug)
    )

    @schema = [
      Seo::StructuredDataBuilder.web_application(
        name: "How Long Ago Was #{@event.title}?",
        url: how_long_ago_url(@event.slug),
        description: @event.description.presence || "Calculate how long ago #{@event.title} was."
      ),
      Seo::StructuredDataBuilder.breadcrumb([
        [ "Home", root_url ],
        [ "How Long Ago", how_long_ago_url("moon-landing") ],
        [ @event.title, how_long_ago_url(@event.slug) ]
      ])
    ]
  end
end
