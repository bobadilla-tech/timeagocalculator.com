require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "static footer pages render successfully" do
    pages = {
      date_calculator_path => "Date Calculator",
      day_of_the_week_path => "Day of the Week",
      recurring_date_finder_path => "Recurring Date Finder",
      week_number_path => "Week Number",
      anniversary_calculator_path => "Anniversary Calculator",
      privacy_policy_path => "Privacy Policy",
      terms_of_service_path => "Terms of Service",
      contact_path => "Contact",
      faqs_path => "FAQs",
      feedback_path => "Give Feedback",
      report_a_bug_path => "Report a Bug"
    }

    pages.each do |path, title|
      get path
      assert_response :success
      assert_select "h1", title
      assert_select "footer"
    end
  end

  test "home footer includes sitemap sections and Bobadilla copyright" do
    get root_path

    assert_response :success
    assert_select "footer" do
      assert_select "h2", "Date Tools"
      assert_select "h2", "Calculators"
      assert_select "h2", "About"
      assert_select "h2", "Feedback"
      assert_select "a[href='http://bobadilla.tech/']", "Bobadilla Technologies"
      assert_select "p", /2025/
        assert_select "a[href='https://www.buymeacoffee.com/']"
        assert_select "a[href='https://www.buymeacoffee.com/'][target='_blank'][rel='noopener']"
        assert_select "a[href='https://facebook.com/'][target='_blank'][rel='noopener']"
        assert_select "a[href='https://twitter.com/'][target='_blank'][rel='noopener']"
    end
  end

  test "feedback form submits and shows thank you" do
    post feedback_path, params: { message: "Great site!" }

    assert_response :redirect
    follow_redirect!
    assert_select "#flash-notice", "Thanks for your feedback."
  end

  test "bug report form submits and shows thank you" do
    post report_a_bug_path, params: { message: "Found a bug on the age calculator." }

    assert_response :redirect
    follow_redirect!
    assert_select "#flash-notice", "Thanks — your bug report has been received."
  end
end
