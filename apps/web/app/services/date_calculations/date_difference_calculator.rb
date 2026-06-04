module DateCalculations
  class DateDifferenceCalculator
    Result = Data.define(:total_days, :business_days, :weeks, :months, :years, :from, :to)

    def initialize(from:, to:)
      @from = from.to_date
      @to   = to.to_date
      @from, @to = @to, @from if @from > @to
    end

    def call
      total_days    = (@to - @from).to_i
      business_days = count_business_days(@from, @to)
      weeks         = total_days / 7
      months        = (@to.year * 12 + @to.month) - (@from.year * 12 + @from.month)
      years         = @to.year - @from.year

      Result.new(total_days:, business_days:, weeks:, months:, years:, from: @from, to: @to)
    end

    private

    def count_business_days(from, to)
      (from..to).count { |d| d.wday.between?(1, 5) }
    end
  end
end
