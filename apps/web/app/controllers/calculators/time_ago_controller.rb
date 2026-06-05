module Calculators
  class TimeAgoController < BaseController
    def show
      set_meta_tags(
        title: "Time Ago Calculator — How Long Ago Was a Date?",
        description: "Calculate how many years, months, days, hours and minutes ago any date was. Get an instant human-readable result.",
        canonical: time_ago_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Time Ago Calculator",
        url: time_ago_calculator_url,
        description: "Calculate how long ago any date was in years, months, and days."
      )

      @featured_events = Event.published.past.sorted_past.limit(8)

      @result = nil
      @error  = nil

      return unless params[:date].present?

      date = parse_date(:date)
      if date.nil?
        @error = "Please enter a valid date."
      elsif date > Date.today
        @error = "That date is in the future. Try the Time Until Calculator."
      else
        @result = DateCalculations::TimeAgoCalculator.new(reference_date: date).call
        @input_date = date
        set_meta_tags(
          title: "How Long Ago Was #{date.strftime("%B %-d, %Y")}?",
          description: "#{date.strftime("%B %-d, %Y")} was #{@result.human}. Full breakdown in years, months, days, hours and minutes."
        )
      end
    end
  end
end
