class AuthorMailer < ApplicationMailer
  default from: Rails.application.credentials.mail.smtp_username

  def signing_request
    @author = params[:author]
    mail(to: @author.email_address, subject: "Please Sign the Document")
  end
end
