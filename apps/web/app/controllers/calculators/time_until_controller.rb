module Calculators
  class TimeUntilController < BaseController
    def show
      set_meta_tags(
        title: "Time Until Calculator — How Long Until a Date?",
        description: "Calculate how many years, months, days, hours and minutes until any future date. Live updating countdown timer.",
        canonical: time_until_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Time Until Calculator",
        url: time_until_calculator_url,
        description: "Calculate how long until any future date with a live countdown timer."
      )

      @result = nil
      @error  = nil

      return unless params[:date].present?

      date = parse_date(:date)
      if date.nil?
        @error = "Please enter a valid date."
      elsif date < Date.today
        @error = "That date is in the past. Try the Time Ago Calculator."
      else
        @result = DateCalculations::TimeUntilCalculator.new(reference_date: date).call
        @input_date = date
        set_meta_tags(
          title: "How Long Until #{date.strftime("%B %-d, %Y")}?",
          description: "There are #{@result.years > 0 ? "#{@result.years} years, " : ""}#{@result.months} months and #{@result.days} days until #{date.strftime("%B %-d, %Y")}."
        )
      end
    end
  end
end
