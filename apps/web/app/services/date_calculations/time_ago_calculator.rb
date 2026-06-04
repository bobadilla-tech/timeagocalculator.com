module DateCalculations
  class TimeAgoCalculator < BaseCalculator
    Result = Data.define(:years, :months, :days, :total_days, :hours, :minutes, :human)

    def call
      return nil if reference_date > now

      years, months, days = decompose_diff(reference_date, now)
      total_days = (now - reference_date).to_i
      total_seconds = (Time.current - reference_date.to_time).to_i
      hours   = total_seconds / 3600
      minutes = total_seconds / 60

      Result.new(
        years:,
        months:,
        days:,
        total_days:,
        hours:,
        minutes:,
        human: human_string(years, months, days)
      )
    end

    private

    def human_string(years, months, days)
      parts = []
      parts << "#{years} #{"year".pluralize(years)}"   if years  > 0
      parts << "#{months} #{"month".pluralize(months)}" if months > 0
      parts << "#{days} #{"day".pluralize(days)}"       if days   > 0
      return "today" if parts.empty?
      parts.to_sentence + " ago"
    end
  end
end
