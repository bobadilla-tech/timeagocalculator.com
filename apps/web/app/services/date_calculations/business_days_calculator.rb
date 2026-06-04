module DateCalculations
  class BusinessDaysCalculator
    BetweenResult = Data.define(:from, :to, :business_days, :total_days, :country_code)
    AddResult     = Data.define(:start_date, :business_days, :result_date, :country_code, :direction)

    def initialize(country_code: nil)
      @country_code  = country_code.presence
      @holiday_cache = {}
    end

    def between(from:, to:)
      from, to = from.to_date, to.to_date
      from, to = to, from if from > to
      total = (to - from).to_i
      biz   = (from..to).count { |d| business_day?(d) }
      BetweenResult.new(from:, to:, business_days: biz, total_days: total, country_code: @country_code)
    end

    def add(from:, days:, direction: :forward)
      date      = from.to_date
      remaining = days.abs
      step      = direction == :backward ? -1 : 1
      while remaining > 0
        date += step
        remaining -= 1 if business_day?(date)
      end
      AddResult.new(start_date: from.to_date, business_days: days, result_date: date,
                    country_code: @country_code, direction:)
    end

    private

    def business_day?(date)
      return false if date.saturday? || date.sunday?
      !holiday?(date)
    end

    def holiday?(date)
      return false unless @country_code
      holidays_for_year(date.year).include?(date)
    end

    def holidays_for_year(year)
      @holiday_cache[year] ||= NagerDateClient.holidays(year:, country_code: @country_code).to_set
    end
  end
end
