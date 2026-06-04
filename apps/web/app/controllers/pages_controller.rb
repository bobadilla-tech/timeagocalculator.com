class PagesController < ApplicationController
  Page = Data.define(:title, :description, :status)

  PAGES = {
    "date_calculator" => Page.new(
      "Date Calculator",
      "Add or subtract days, weeks, months, and years from a date.",
      "This calculator page is scaffolded and ready for the full date math experience."
    ),
    "day_of_the_week" => Page.new(
      "Day of the Week",
      "Find the weekday for any past or future date.",
      "This calculator page is scaffolded and ready for the weekday lookup tool."
    ),
    "recurring_date_finder" => Page.new(
      "Recurring Date Finder",
      "Plan repeating dates and discover upcoming occurrences.",
      "This tool page is scaffolded and ready for recurrence rules and results."
    ),
    "week_number" => Page.new(
      "Week Number",
      "Look up ISO week numbers and calendar week details.",
      "This calculator page is scaffolded and ready for week-number calculations."
    ),
    "anniversary_calculator" => Page.new(
      "Anniversary Calculator",
      "Calculate upcoming anniversaries and milestone dates.",
      "This calculator page is scaffolded and ready for anniversary results."
    ),
    "privacy_policy" => Page.new(
      "Privacy Policy",
      "Learn how Time Ago Calculator handles privacy.",
      "This policy page has a basic structure and needs final legal copy."
    ),
    "terms_of_service" => Page.new(
      "Terms of Service",
      "Review the terms for using Time Ago Calculator.",
      "This terms page has a basic structure and needs final legal copy."
    ),
    "contact" => Page.new(
      "Contact",
      "Get in touch with the Time Ago Calculator team.",
      "This contact page is scaffolded and ready for a form or contact address."
    ),
    "faqs" => Page.new(
      "FAQs",
      "Answers to common questions about date calculators and countdowns.",
      "This FAQ page is scaffolded and ready for detailed support content."
    ),
    "feedback" => Page.new(
      "Give Feedback",
      "Share ideas, requests, and suggestions for improving the site.",
      "This feedback page is scaffolded and ready for a form or external feedback link."
    ),
    "report_a_bug" => Page.new(
      "Report a Bug",
      "Tell us when something is broken or confusing.",
      "This bug report page is scaffolded and ready for an issue intake flow."
    )
  }.freeze

  before_action :set_page
  skip_before_action :set_page, only: [:submit_feedback, :submit_report_a_bug]

  PAGES.each_key do |page_action|
    define_method(page_action) do
      if lookup_context.template_exists?(page_action, [controller_path], false)
        render action: page_action
      else
        render :show
      end
    end
  end

  def submit_feedback
    message = params[:message]

    if message.blank?
      flash[:alert] = "Message can't be blank"
      redirect_to feedback_path
      return
    end

    # TODO: persist or deliver feedback (email, DB, external service)
    flash[:notice] = "Thanks for your feedback."
    redirect_to feedback_path
  end

  def submit_report_a_bug
    message = params[:message]

    if message.blank?
      flash[:alert] = "Please describe the bug"
      redirect_to report_a_bug_path
      return
    end

    # TODO: persist or deliver bug report (email, issue tracker integration)
    flash[:notice] = "Thanks — your bug report has been received."
    redirect_to report_a_bug_path
  end

  private

  def set_page
    @page = PAGES.fetch(action_name)

    set_meta_tags(
      title: @page.title,
      description: @page.description,
      canonical: url_for(only_path: false)
    )
  end
end
