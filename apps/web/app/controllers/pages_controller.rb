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
    name = params[:name]
    email = params[:email]
    message = params[:message]

    if message.blank?
      flash[:alert] = "Message can't be blank"
      redirect_to feedback_path
      return
    end

    begin
      FeedbackMailer.feedback(name: name, email: email, message: message).deliver_now
      flash[:notice] = "Thanks for your feedback."
    rescue => e
      Rails.logger.error("Feedback delivery failed: "+e.message)
      flash[:alert] = "There was a problem sending your feedback. Please try again later."
    end

    redirect_to feedback_path
  end

  def submit_report_a_bug
    email = params[:email]
    message = params[:message]

    if message.blank?
      flash[:alert] = "Please describe the bug"
      redirect_to report_a_bug_path
      return
    end

    begin
      FeedbackMailer.bug_report(email: email, message: message).deliver_now
      flash[:notice] = "Thanks — your bug report has been received."
    rescue => e
      Rails.logger.error("Bug report delivery failed: "+e.message)
      flash[:alert] = "There was a problem submitting your bug report. Please try again later."
    end

    redirect_to report_a_bug_path
  end

  private

  def set_page
    @page = PAGES.fetch(action_name)

    set_meta_tags(
      title: @page.title,
      description: @page.description,
      canonical: url_for(only_path: false),
      og: {
        title: @page.title,
        description: @page.description,
        image: (action_name == 'date_calculator' ? (request.base_url + "/social-preview.svg") : (request.base_url + "/icon.jpeg"))
      },
      twitter: {
        title: @page.title,
        description: @page.description,
        image: (action_name == 'date_calculator' ? (request.base_url + "/social-preview.svg") : (request.base_url + "/icon.jpeg"))
      }
    )
    app_schema = Seo::StructuredDataBuilder.web_application(
      name: @page.title,
      url: url_for(only_path: false),
      description: @page.description
    )

    # Add page-specific structured data (FAQ) for Date Calculator
    if action_name == 'date_calculator'
      faq_pairs = {
        "How do I add months to a date?" => "Select 'Months' as the unit, set the amount, and choose Add. Month-end dates are handled so Jan 31 + 1 month -> Feb 28/29.",
        "Can I subtract weeks?" => "Yes — choose Subtract and select Weeks as the unit to go back in time by the specified number of weeks.",
        "Does the calculator respect timezones?" => "The calculator uses the browser's timezone for previews; server-side results use the site's configured timezone for authoritative results."
      }

      howto_steps = [
        { name: "Choose a start date", text: "Pick the date you want to calculate from using the Start Date field." },
        { name: "Pick an operation", text: "Select Add to move forward or Subtract to move backward in time." },
        { name: "Enter amount and unit", text: "Set the amount and choose Days, Weeks, Months, or Years." },
        { name: "Calculate", text: "Click Calculate Date to see the result. Quick-buttons provide common presets." }
      ]

      @schema = [app_schema, Seo::StructuredDataBuilder.faq(faq_pairs), Seo::StructuredDataBuilder.howto(name: @page.title, description: @page.description, steps: howto_steps)]
      # Use a custom social preview image for better Open Graph cards
      @og_image = request.base_url + '/social-preview.svg'
    else
      @schema = app_schema
    end
  end
end
