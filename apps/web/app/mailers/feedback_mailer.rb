class FeedbackMailer < ApplicationMailer
  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL", "support@howlongagogo.com")

  def feedback(name:, email:, message:)
    @name = name.presence || "Anonymous"
    @message = message
    @from = email.presence || "noreply@howlongagogo.com"

    mail to: ADMIN_EMAIL, from: @from, subject: "Website feedback from #{@name}"
  end

  def bug_report(email:, message:)
    @message = message
    @from = email.presence || "noreply@howlongagogo.com"

    mail to: ADMIN_EMAIL, from: @from, subject: "Bug report from website"
  end
end
