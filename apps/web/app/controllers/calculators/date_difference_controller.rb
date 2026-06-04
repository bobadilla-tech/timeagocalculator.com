module Calculators
  class DateDifferenceController < BaseController
    def show
      set_meta_tags(
        title: "Date Difference Calculator — Days Between Two Dates",
        description: "Calculate the number of days, weeks, months, and business days between any two dates.",
        canonical: date_difference_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Date Difference Calculator",
        url: date_difference_calculator_url,
        description: "Calculate the exact number of days, weeks, months and business days between two dates."
      )

      @result = nil
      @error  = nil

      return unless params[:from].present? && params[:to].present?

      from = parse_date(:from)
      to   = parse_date(:to)

      if from.nil? || to.nil?
        @error = "Please enter valid dates for both fields."
      else
        @result = DateCalculations::DateDifferenceCalculator.new(from: from, to: to).call
      end
    end
  end
end
