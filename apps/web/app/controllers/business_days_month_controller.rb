class BusinessDaysMonthController < ApplicationController
  include SeoMetaTaggable

  MONTH_NAMES = Date::MONTHNAMES.compact.map(&:downcase).freeze

  def this_month
    year  = Date.today.year
    month = Date::MONTHNAMES[Date.today.month].downcase
    if params[:country].present?
      redirect_to business_days_month_country_path(params[:country], year, month), status: :moved_permanently
    else
      redirect_to business_days_month_path(year, month), status: :moved_permanently
    end
  end

  def show
    month_name = params[:month].downcase
    month_idx  = MONTH_NAMES.index(month_name)
    return render_not_found unless month_idx

    year = params[:year].to_i
    return render_not_found unless year.between?(2000, 2050)

    @country_code = nil
    @country_name = nil

    if params[:country].present?
      @country_code = NagerDateClient.country_code_for_slug(params[:country])
      return render_not_found unless @country_code
      @country_name = NagerDateClient.available_countries
                        .find { |c| c["countryCode"] == @country_code }&.dig("name")
    end

    @year       = year
    @month_num  = month_idx + 1
    @month_name = Date::MONTHNAMES[@month_num]
    @from       = Date.new(@year, @month_num, 1)
    @to         = @from.end_of_month

    calc    = DateCalculations::BusinessDaysCalculator.new(country_code: @country_code)
    @result = calc.between(from: @from, to: @to)

    @holidays = if @country_code
      NagerDateClient.holidays_with_names(year: @year, country_code: @country_code)
                     .select { |h| Date.parse(h["date"]).month == @month_num }
                     .map { |h| { date: Date.parse(h["date"]), name: h["name"] } }
    else
      []
    end

    location_suffix = @country_name ? " in #{@country_name}" : ""
    canonical = @country_code \
      ? business_days_month_country_url(params[:country], @year, params[:month]) \
      : business_days_month_url(@year, params[:month])

    set_meta_tags(
      title: "Business Days in #{@month_name} #{@year}#{location_suffix}",
      description: "There are #{@result.business_days} business days in #{@month_name} #{@year}#{location_suffix}. #{@holidays.any? ? "#{@holidays.size} public holiday#{"s" if @holidays.size != 1} excluded." : "Weekends excluded."}",
      canonical:
    )

    @schema = Seo::StructuredDataBuilder.web_application(
      name: "Business Days in #{@month_name} #{@year}#{location_suffix}",
      url: canonical,
      description: "How many business days are in #{@month_name} #{@year}#{location_suffix}?"
    )

    @prev_month = @from.prev_month
    @next_month = @from.next_month
  end

  private

  def render_not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
