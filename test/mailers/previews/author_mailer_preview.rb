# Preview all emails at http://localhost:3000/rails/mailers/author_mailer
class AuthorMailerPreview < ActionMailer::Preview
  def send_document_group_link
    # Find a DocumentGroup for previewing.
    # In a real application, you would use a record from the database or a factory.
    # Example: DocumentGroup.last

    # Using a placeholder object for demonstration:
    document_group = DocumentGroup.first || DocumentGroup.new(
      token: "preview_token",
      author: Author.new(email_address: "test@example.com"),
      documents: [ Document.new, Document.new ]
    )

    AuthorMailer.send_document_group_link(document_group)
  end
end
