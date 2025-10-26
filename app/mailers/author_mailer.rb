class AuthorMailer < ApplicationMailer
  def send_access_link(author, access_token)
    @author = author
    @access_token = access_token
    @documents_count = access_token.document_ids.count
    @expires_at = access_token.expires_at
    @access_url = author_access_url(token: access_token.token)

    mail(to: author.email_address, from: "donotreply@expertus.media", subject: "Автор Експертус: документи на підпис [#{@documents_count} шт.]")
  end
end
