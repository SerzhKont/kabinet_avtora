class NotificationMailer < ApplicationMailer
  default from: ENV["AZURE_EMAIL_USER"]

  def signing_request(author)
    author.regenerate_access_token_with_expiry(7)  # 7 дней для токена
    @author = author
    @documents = author.documents.where(status: [ "pending", "linked" ])
    @magic_link = author_documents_url(access_token: author.access_token)
    mail(to: author.email_address, subject: "Документи для підпису")
  end
end
