class AuthorMailer < ApplicationMailer
  def send_document_group_link(document_group)
    @group = document_group
    @author = @group.author
    @author_code = @author.code
    @url = document_group_url(@group.token)
    @expires_at = @group.expires_at
    @created_at = @group.created_at.strftime("%d.%m.%Y")

    mail(to: @author.email_address, from: "donotreply@expertus.media", subject: "ЕКСПЕРТУС: документи на підпис від #{@created_at} за кодом автора #{@author_code}")
  end
end
