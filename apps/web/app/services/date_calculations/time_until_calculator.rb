module DateCalculations
  class TimeUntilCalculator < BaseCalculator
    Result = Data.define(:years, :months, :days, :total_seconds, :target_timestamp_ms, :is_past)

    def call
      if reference_date <= now
        return Result.new(years: 0, months: 0, days: 0, total_seconds: 0,
                          target_timestamp_ms: 0, is_past: true)
      end

      years, months, days = decompose_diff(now, reference_date)
      target_time = reference_date.to_time
      total_seconds = (target_time - Time.current).to_i
      target_timestamp_ms = (target_time.to_i * 1000)

      Result.new(years:, months:, days:, total_seconds:, target_timestamp_ms:, is_past: false)
    end
  end
end
