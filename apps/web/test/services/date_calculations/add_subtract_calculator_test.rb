require "test_helper"

class DateCalculations::AddSubtractCalculatorTest < ActiveSupport::TestCase
  test "adds days correctly" do
    base = Date.parse("2026-06-01")
    result = DateCalculations::AddSubtractCalculator.new(base_date: base).call(operation: "add", amount: 30, unit: "days")
    assert_equal Date.parse("2026-07-01"), result.result_date
  end

  test "handles month end smartly (jan 31 + 1 month => feb 28)" do
    base = Date.parse("2026-01-31")
    result = DateCalculations::AddSubtractCalculator.new(base_date: base).call(operation: "add", amount: 1, unit: "months")
    assert_equal Date.parse("2026-02-28"), result.result_date
  end

  test "subtracts weeks correctly" do
    base = Date.parse("2026-06-05")
    result = DateCalculations::AddSubtractCalculator.new(base_date: base).call(operation: "subtract", amount: 2, unit: "weeks")
    assert_equal Date.parse("2026-05-22"), result.result_date
  end
end
