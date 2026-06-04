module DateCalculations
  class AgeCalculator < BaseCalculator
    Result = Data.define(:years, :months, :days, :next_birthday_in_days, :birthdate)

    def call
      return nil if reference_date > now

      years, months, days = decompose_diff(reference_date, now)

      next_bday = begin
        Date.new(now.year, reference_date.month, reference_date.day)
      rescue Date::Error
        # Feb 29 on non-leap year → use Mar 1
        Date.new(now.year, 3, 1)
      end
      next_bday = next_bday.next_year if next_bday <= now
      next_birthday_in_days = (next_bday - now).to_i

      Result.new(years:, months:, days:, next_birthday_in_days:, birthdate: reference_date)
    end
  end
end
