require "test_helper"

class DateCalculations::HoursAgoCalculatorTest < ActiveSupport::TestCase
  test "calculates hours and minutes ago correctly" do
    base = Time.zone.parse("2026-06-05 08:51:00")
    result = DateCalculations::HoursAgoCalculator.new(base_time: base).call(hours: 3, minutes: 15)

    expected = Time.zone.parse("2026-06-05 05:36:00")
    assert_equal expected.to_i, result.result_time.to_i
  end
end
