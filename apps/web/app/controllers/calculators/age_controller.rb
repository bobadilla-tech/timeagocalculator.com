module Calculators
  class AgeController < BaseController
    def show
      set_meta_tags(
        title: "Age Calculator — How Old Am I?",
        description: "Calculate your exact age in years, months, and days. Find out how many days until your next birthday.",
        canonical: age_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Age Calculator",
        url: age_calculator_url,
        description: "Calculate your exact age in years, months, and days from your date of birth."
      )

      @result = nil
      @error  = nil

      return unless params[:birthdate].present?

      date = parse_date(:birthdate)
      if date.nil?
        @error = "Please enter a valid birthdate."
      elsif date > Date.today
        @error = "Birthdate cannot be in the future."
      else
        @result = DateCalculations::AgeCalculator.new(reference_date: date).call
        set_meta_tags(
          title: "Age for Someone Born on #{date.strftime("%B %-d, %Y")}",
          description: "Someone born on #{date.strftime("%B %-d, %Y")} is #{@result.years} years, #{@result.months} months and #{@result.days} days old."
        )
      end
    end
  end
end
