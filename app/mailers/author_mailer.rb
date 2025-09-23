class AuthorMailer < ApplicationMailer
  def signing_request
    @author = params[:author]
    mail(to: @author.email_address, from: "donotreply@expertus.media", subject: "Please Sign the Document")
  end
end
