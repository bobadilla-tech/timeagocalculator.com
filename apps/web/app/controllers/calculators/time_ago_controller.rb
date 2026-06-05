module Calculators
  class TimeAgoController < BaseController
    def show
      set_meta_tags(
        title: "Date Calculator — How Long Ago or Until Any Date",
        description: "Enter any date — past or future — and find out exactly how long ago it was or how long until it arrives.",
        canonical: time_ago_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Date Calculator",
        url: time_ago_calculator_url,
        description: "Calculate how long ago any date was or how long until a future date."
      )

      @featured_events = Event.published.past.sorted_past.limit(8)

      return unless params[:date].present?

      date = parse_date(:date)
      unless date
        @error = "Please enter a valid date."
        return
      end

      redirect_to date_page_path(date.year, date.strftime("%B").downcase, date.day)
    end
  end
end
