class DatePagesController < ApplicationController
  MONTH_NAMES = Date::MONTHNAMES.compact.map(&:downcase).freeze

  def show
    year      = params[:year].to_i
    month_idx = MONTH_NAMES.index(params[:month].downcase.strip)
    return redirect_to root_path unless month_idx
    month = month_idx + 1
    day   = params[:day].to_i

    begin
      @input_date = Date.new(year, month, day)
    rescue Date::Error
      return redirect_to root_path
    end

    @is_future = @input_date > Date.today

    if @is_future
      @result        = DateCalculations::TimeUntilCalculator.new(reference_date: @input_date).call
      total_secs     = @result.total_seconds
      @total_seconds = total_secs
      @total_days    = total_secs / 86400
      @total_hours   = total_secs / 3600
      @total_minutes = total_secs / 60
      @total_weeks   = @total_days / 7
      @total_months  = @result.years * 12 + @result.months
      @target_ms     = @result.target_timestamp_ms

      set_meta_tags(
        title:       "How Long Until #{@input_date.strftime("%B %-d, %Y")}?",
        description: "#{@input_date.strftime("%B %-d, %Y")} is in #{@total_days} #{"day".pluralize(@total_days)}. Live countdown with days, hours, minutes and seconds.",
        canonical:   date_page_url(year, params[:month], day)
      )
    else
      @result         = DateCalculations::TimeAgoCalculator.new(reference_date: @input_date).call
      total_secs      = (Time.current - @input_date.to_time).to_i
      @total_seconds  = total_secs
      @comp_hours     = (total_secs % 86400) / 3600
      @comp_minutes   = (total_secs % 3600) / 60
      @total_weeks    = @result.total_days / 7
      @total_months   = @result.years * 12 + @result.months
      @rendered_at_ms = (Time.current.to_f * 1000).to_i

      set_meta_tags(
        title:       "How Long Ago Was #{@input_date.strftime("%B %-d, %Y")}?",
        description: "#{@input_date.strftime("%B %-d, %Y")} was #{@result.human}. Full breakdown in days, hours, minutes and seconds.",
        canonical:   date_page_url(year, params[:month], day)
      )

      today = Date.today
      @age_if_born = today.year - @input_date.year -
        ((today.month > @input_date.month || (today.month == @input_date.month && today.day >= @input_date.day)) ? 0 : 1)
    end

    @events_on_date = Event.published
      .where.not(category: "leaders")
      .where("starts_at::date = ?", @input_date)
      .order(title: :asc)
      .limit(8)

    @leaders_on_date = Event.published
      .where(category: "leaders")
      .where("starts_at::date <= ?", @input_date)
      .where("ends_at IS NULL OR ends_at::date >= ?", @input_date)
  end
end
