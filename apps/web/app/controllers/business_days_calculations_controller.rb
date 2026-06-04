class BusinessDaysCalculationsController < ApplicationController
  include SeoMetaTaggable

  before_action :set_calculation, only: [ :show, :destroy ]

  def create
    mode = params[:mode].presence_in(%w[between add]) || "between"
    from = parse_date_param(params[:from])
    return redirect_to business_days_calculator_path, alert: "Invalid start date." unless from

    calc  = DateCalculations::BusinessDaysCalculator.new(country_code: params[:country_code].presence)
    attrs = { mode:, from_date: from, country_code: params[:country_code].presence }

    if mode == "between"
      to = parse_date_param(params[:to])
      return redirect_to business_days_calculator_path, alert: "Invalid end date." unless to
      result = calc.between(from:, to:)
      attrs.merge!(to_date: to, result_days: result.business_days)
    else
      days      = params[:days].to_i
      direction = params[:direction] == "subtract" ? "backward" : "forward"
      return redirect_to business_days_calculator_path, alert: "Enter a positive number of days." unless days > 0
      result = calc.add(from:, days:, direction: direction.to_sym)
      attrs.merge!(input_days: days, direction:, result_days: result.business_days, result_date: result.result_date)
    end

    calculation = BusinessDaysCalculation.new(attrs)
    calculation.user = Current.user if Current.user
    calculation.save!
    redirect_to business_days_calculation_path(calculation.token)
  end

  def show
    calc = DateCalculations::BusinessDaysCalculator.new(country_code: @calculation.country_code)
    if @calculation.mode == "between"
      @result = calc.between(from: @calculation.from_date, to: @calculation.to_date)
    else
      @result = calc.add(
        from:      @calculation.from_date,
        days:      @calculation.input_days,
        direction: @calculation.direction.to_sym
      )
    end

    @country_name = if @calculation.country_code.present?
      NagerDateClient.available_countries
        .find { |c| c["countryCode"] == @calculation.country_code }&.dig("name")
    end

    result_summary = if @result.is_a?(DateCalculations::BusinessDaysCalculator::BetweenResult)
      "#{@result.business_days} business days"
    else
      @result.result_date.strftime("%B %-d, %Y")
    end

    set_meta_tags(
      title: "Business Days Calculation — #{result_summary}",
      description: "Shared business days calculation. #{result_summary}#{@country_name ? " (#{@country_name})" : ""}."
    )
  end

  def destroy
    return redirect_to dashboard_path, alert: "Not authorized." unless @calculation.owned_by?(Current.user)
    @calculation.destroy
    redirect_to dashboard_path, notice: "Calculation deleted."
  end

  private

  def set_calculation
    @calculation = BusinessDaysCalculation.find_by!(token: params[:token])
  end

  def parse_date_param(val)
    Date.parse(val.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
