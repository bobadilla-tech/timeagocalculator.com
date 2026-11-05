module DateCalculations
  class AddSubtractCalculator
    Result = Struct.new(:result_date)

    def initialize(base_date:)
      @base_date = base_date.to_date
    end

    def call(operation:, amount:, unit:)
      amt = amount.to_i
      case unit.to_s
      when "days"
        res = operation == "subtract" ? @base_date - amt : @base_date + amt
      when "weeks"
        days = amt * 7
        res = operation == "subtract" ? @base_date - days : @base_date + days
      when "months"
        delta = operation == "subtract" ? -amt : amt
        res = @base_date.advance(months: delta)
      when "years"
        delta = operation == "subtract" ? -amt : amt
        res = @base_date.advance(years: delta)
      else
        res = @base_date
      end

      Result.new(res)
    end
  end
end
