require "test_helper"

class DateCalculatorPageTest < ActionDispatch::IntegrationTest
  test "date calculator form renders with expected inputs" do
    get date_calculator_path
    assert_response :success
    assert_select "input[data-date-calculator-target='date']"
    assert_select "select[data-date-calculator-target='operation']"
    assert_select "input[data-date-calculator-target='amount']"
    assert_select "select[data-date-calculator-target='unit']"
    assert_select "button", /Calculate Date/
  end
end
