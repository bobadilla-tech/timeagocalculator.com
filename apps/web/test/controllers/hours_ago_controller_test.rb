require "test_helper"

class HoursAgoControllerTest < ActionDispatch::IntegrationTest
  test "hours ago page renders" do
    get hours_ago_calculator_path
    assert_response :success
    assert_select "h1", "Hours Ago Calculator"
  end
end
