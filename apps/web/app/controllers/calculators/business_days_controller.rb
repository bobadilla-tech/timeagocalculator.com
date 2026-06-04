module Calculators
  class BusinessDaysController < BaseController
    def show
      set_meta_tags(
        title: "Business Days Calculator — Working Days Between Dates",
        description: "Calculate working days between two dates, or find a date N business days away. Excludes weekends and public holidays for 90+ countries.",
        canonical: business_days_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Business Days Calculator",
        url: business_days_calculator_url,
        description: "Calculate the number of working days between two dates, excluding weekends and public holidays."
      )

      @countries = NagerDateClient.available_countries
      @mode      = params[:mode].presence_in(%w[between add]) || "between"
      @result    = nil
      @error     = nil

      return unless params[:from].present?

      calc = DateCalculations::BusinessDaysCalculator.new(country_code: params[:country_code].presence)

      if @mode == "between"
        return unless params[:to].present?
        from = parse_date(:from)
        to   = parse_date(:to)
        if from.nil? || to.nil?
          @error = "Please enter valid dates for both fields."
          return
        end
        @result = calc.between(from:, to:)
      else
        return unless params[:days].present?
        from = parse_date(:from)
        days = params[:days].to_i
        if from.nil? || days <= 0
          @error = "Please enter a valid start date and a positive number of days."
          return
        end
        direction = params[:direction] == "subtract" ? :backward : :forward
        @result = calc.add(from:, days:, direction:)
      end
    end
  end
end
