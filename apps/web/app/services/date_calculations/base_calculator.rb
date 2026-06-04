module DateCalculations
  class BaseCalculator
    attr_reader :reference_date, :now

    def initialize(reference_date:, now: Time.current)
      @reference_date = reference_date.to_date
      @now = now.to_date
    end

    private

    def decompose_diff(from, to)
      years  = to.year  - from.year
      months = to.month - from.month
      days   = to.day   - from.day

      if days < 0
        months -= 1
        # days in the month we're borrowing from
        days += Date.new(to.year, to.month, 1).prev_month.then { |d| Date.new(d.year, d.month, -1).day }
      end

      if months < 0
        years  -= 1
        months += 12
      end

      [ years, months, days ]
    end
  end
end
