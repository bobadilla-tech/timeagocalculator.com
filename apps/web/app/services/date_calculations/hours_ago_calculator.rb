module DateCalculations
  class HoursAgoCalculator
    Result = Struct.new(:result_time)

    def initialize(base_time:)
      @base_time = base_time.in_time_zone
    end

    def call(hours: 0, minutes: 0)
      delta = hours.to_i.hours + minutes.to_i.minutes
      res = @base_time - delta
      Result.new(res)
    end
  end
end
