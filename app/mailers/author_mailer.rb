class AuthorMailer < ApplicationMailer
  def send_document_group_link(document_group)
    @group = document_group
    @author = @group.author
    @url = document_group_url(@group.token)

    mail(to: @author.email_address, from: "donotreply@expertus.media", subject: "Автор Експертус: документи на підпис [#{@group.documents.count} шт.]")
  end
end
