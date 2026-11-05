module Calculators
  class DayOfTheWeekController < BaseController
    def show
      set_meta_tags(
        title:       "Day of the Week Calculator — What Day Was Any Date?",
        description: "Find out what day of the week any date falls on. Look up any historical or future date instantly.",
        canonical:   day_of_the_week_url
      )

      today            = Date.today
      start_of_week    = today.beginning_of_week(:monday)
      @today           = today
      @this_week       = (start_of_week..(start_of_week + 6)).to_a
      @first_of_months = (1..6).map { |i| (today >> i).beginning_of_month }

      year = today.year
      notable_raw = [
        [ Date.new(year, 1, 1),  "New Year's Day" ],
        [ Date.new(year, 7, 4),  "Independence Day" ],
        [ Date.new(year, 10, 31), "Halloween" ],
        [ Date.new(year, 12, 25), "Christmas Day" ],
        [ Date.new(year, 12, 31), "New Year's Eve" ]
      ]
      @notable_dates = notable_raw.map do |date, name|
        date = Date.new(year + 1, date.month, date.day) if date < today
        { date: date, name: name }
      end

      @popular_countdowns = Event.published.upcoming
        .where("lower(title) LIKE ? OR lower(title) LIKE ?", "christmas%", "new year%")
        .sorted_upcoming.limit(4)

      return unless params[:year].present? && params[:month].present? && params[:day].present?

      begin
        @input_date    = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
        @day_of_week   = @input_date.strftime("%A")
        @day_of_year   = @input_date.yday
        @week_number   = @input_date.cweek
        @quarter       = ((@input_date.month - 1) / 3) + 1
        @is_leap       = @input_date.leap?
        @days_in_month = Date.new(@input_date.year, @input_date.month, -1).day
        @is_past       = @input_date < today

        set_meta_tags(
          title:     "What Day of the Week Was #{@input_date.strftime("%B %-d, %Y")}?",
          canonical: day_of_the_week_url(year: @input_date.year, month: @input_date.month, day: @input_date.day)
        )
      rescue Date::Error, ArgumentError
        @error = "Please enter a valid date."
      end
    end
  end
end
