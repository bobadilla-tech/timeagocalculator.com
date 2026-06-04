class EventsController < ApplicationController
  include SeoMetaTaggable

  UPCOMING_LIMIT = 50
  PAST_LIMIT     = 50

  def index
    @categories = Event::CATEGORIES
    @category   = params[:category].presence
    @region     = params[:region].presence

    base = Event.published
    base = base.by_category(@category) if @category
    base = base.for_region(@region)    if @region

    @upcoming = base.sorted_upcoming.limit(UPCOMING_LIMIT)
    @past     = base.sorted_past.limit(PAST_LIMIT)
    @featured = Event.published.featured.sorted_upcoming.first

    set_meta_tags(
      title: "Event Countdowns — Holidays, Sports & More",
      description: "Countdown to upcoming events and see how long ago past events were. Holidays, sports, cultural events and more.",
      canonical: events_url
    )
  end

  def show_event
    @event = Event.published.find_by!(slug: params[:slug])
    @faq   = @event.faq

    if @event.upcoming?
      render_upcoming_event
    else
      render_past_event
    end
  end

  # Legacy "how long ago" route — redirects upcoming events to canonical /events/:slug
  def show
    @event = Event.published.find_by!(slug: params[:slug])
    return redirect_to event_path(@event.slug), status: :moved_permanently if @event.upcoming?

    @result = @event.time_ago
    @faq    = @event.faq

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
        [ "Historical Events", how_long_ago_url("moon-landing") ],
        [ @event.title, how_long_ago_url(@event.slug) ]
      ]),
      faq_schema(@faq)
    ].compact
  end

  private

  def render_upcoming_event
    days  = @event.days_until
    weeks = @event.weeks_until

    set_meta_tags(
      title: "How Long Until #{@event.title}? #{days} Days",
      description: "#{@event.title} is in #{days} days (#{weeks} weeks) on #{@event.starts_at.strftime("%B %-d, %Y")}.",
      canonical: event_url(@event.slug)
    )

    @schema = [
      Seo::StructuredDataBuilder.web_application(
        name: "How Long Until #{@event.title}?",
        url: event_url(@event.slug),
        description: @event.description.presence || "Countdown to #{@event.title}."
      ),
      Seo::StructuredDataBuilder.breadcrumb([
        [ "Home", root_url ],
        [ "Event Countdowns", events_url ],
        [ @event.title, event_url(@event.slug) ]
      ]),
      faq_schema(@faq)
    ].compact

    render :show_event
  end

  def render_past_event
    @result = @event.time_ago

    set_meta_tags(
      title: "How Long Ago Was #{@event.title}?",
      description: "#{@event.title} was #{@result&.human || "a historical event"} on #{@event.starts_at.strftime("%B %-d, %Y")}.",
      canonical: event_url(@event.slug)
    )

    @schema = [
      Seo::StructuredDataBuilder.web_application(
        name: "How Long Ago Was #{@event.title}?",
        url: event_url(@event.slug),
        description: @event.description.presence || "See how long ago #{@event.title} was."
      ),
      Seo::StructuredDataBuilder.breadcrumb([
        [ "Home", root_url ],
        [ "Event Countdowns", events_url ],
        [ @event.title, event_url(@event.slug) ]
      ]),
      faq_schema(@faq)
    ].compact

    render :show_event
  end

  def faq_schema(faq)
    return nil if faq.blank?
    {
      "@context" => "https://schema.org",
      "@type"    => "FAQPage",
      "mainEntity" => faq.map do |item|
        {
          "@type"          => "Question",
          "name"           => item[:q],
          "acceptedAnswer" => { "@type" => "Answer", "text" => item[:a] }
        }
      end
    }
  end
end
