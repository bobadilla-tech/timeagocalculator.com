class EventsController < ApplicationController
  include SeoMetaTaggable

  UPCOMING_LIMIT  = 100
  PAST_LIMIT      = 30
  HISTORICAL_LIMIT = 200

  def index
    @categories  = Event::CATEGORIES
    @category    = params[:category].presence
    @region      = params[:region].presence
    @q           = params[:q].presence
    @filtered    = @category || @region || @q

    @featured = Event.published.featured.sorted_upcoming.first

    if @filtered
      base      = Event.published.upcoming
      base      = base.by_category(@category) if @category
      base      = base.for_region(@region)    if @region
      base      = base.where("title ILIKE ?", "%#{@q}%") if @q
      @upcoming = base.sorted_upcoming.limit(UPCOMING_LIMIT)
    else
      excluded_ids = [ @featured&.id ].compact
      # Sidebar: next events that have an image, fallback to any
      @coming_up = Event.published.upcoming
                        .where.not(id: excluded_ids)
                        .where.not(image_url: nil)
                        .sorted_upcoming.limit(6)
      @coming_up = Event.published.upcoming
                        .where.not(id: excluded_ids)
                        .sorted_upcoming.limit(6) if @coming_up.empty?
      excluded_ids += @coming_up.map(&:id)
      # Highlights: curated annual events with images
      @highlights = Event.published.upcoming
                         .where(recurrence: "annual", source: "curated")
                         .where.not(id: excluded_ids)
                         .where.not(image_url: nil)
                         .sorted_upcoming.limit(4)
      @upcoming   = Event.published.upcoming
                         .where.not(id: excluded_ids + @highlights.map(&:id))
                         .sorted_upcoming.limit(UPCOMING_LIMIT)
    end

    set_meta_tags(
      title: "Event Countdowns — Holidays, Sports & More",
      description: "Countdown to upcoming events and see how long ago past events were. Holidays, sports, cultural events and more.",
      canonical: events_url
    )
  end

  def historical
    @categories = Event::CATEGORIES
    @category   = params[:category].presence
    @region     = params[:region].presence
    @q          = params[:q].presence
    @year       = params[:year].presence&.to_i

    base = Event.published.past
    base = base.by_category(@category) if @category
    base = base.for_region(@region)    if @region
    base = base.where("title ILIKE ?", "%#{@q}%") if @q
    base = base.where("EXTRACT(YEAR FROM starts_at) = ?", @year) if @year

    @events = base.sorted_past.limit(HISTORICAL_LIMIT)

    set_meta_tags(
      title: "Historical Events — How Long Ago Was?",
      description: "Browse past events and discover how long ago they happened.",
      canonical: historical_events_url
    )
  end

  def by_category
    @category = params[:category]
    return redirect_to events_path unless Event::CATEGORIES.include?(@category)

    base      = Event.published.by_category(@category)
    @upcoming = base.sorted_upcoming.limit(UPCOMING_LIMIT)
    @past     = base.sorted_past.limit(PAST_LIMIT)

    label = @category.titleize
    set_meta_tags(
      title: "#{label} Event Countdowns",
      description: "Upcoming #{label.downcase} events with countdowns and historical #{label.downcase} events.",
      canonical: events_by_category_url(@category)
    )
  end

  def by_country
    @country_slug = params[:country]
    @year         = params[:year].presence&.to_i
    @country_code = Events::CountryUtils.code_from_slug(@country_slug)
    return redirect_to events_path unless @country_code

    @country_name = Events::CountryUtils.country_name(@country_code)
    @categories   = Event::CATEGORIES
    @available_years = Event.published
                            .for_region(@country_code)
                            .distinct
                            .pluck(Arel.sql("EXTRACT(YEAR FROM starts_at)::int"))
                            .sort
                            .reverse

    base = Event.published.for_region(@country_code)
    base = base.where("EXTRACT(YEAR FROM starts_at) = ?", @year) if @year

    @upcoming = base.sorted_upcoming.limit(UPCOMING_LIMIT)
    @past     = base.sorted_past.limit(PAST_LIMIT)

    title_suffix = @year ? " in #{@year}" : ""
    set_meta_tags(
      title: "#{@country_name} Event Countdowns#{title_suffix}",
      description: "Upcoming holidays and events in #{@country_name}#{title_suffix} with live countdowns.",
      canonical: @year ? events_by_country_year_url(@country_slug, @year) : events_by_country_url(@country_slug)
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
    @result = @event.time_until
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
