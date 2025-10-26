class DocumentLinkSender
  DOCUMENTS_PER_GROUP = 7

  def initialize(document_ids)
    @document_ids = document_ids
  end

  def call
    linked_documents = Document.where(id: @document_ids)
                              .linked
                              .includes(:author)
                              .where.not(author_id: nil)

    grouped_documents = group_documents_by_author(linked_documents)

    results = {
      total_authors: 0,
      total_emails_sent: 0,
      errors: []
    }

    grouped_documents.each do |author, document_groups|
      results[:total_authors] += 1

      document_groups.each do |documents|
        begin
          send_email_to_author(author, documents)
          results[:total_emails_sent] += 1
        rescue => e
          results[:errors] << { author_id: author.id, error: e.message }
        end
      end
    end

    results
  end

  private

  def group_documents_by_author(documents)
    documents.group_by(&:author).transform_values do |docs|
      docs.each_slice(DOCUMENTS_PER_GROUP).to_a
    end
  end

  def send_email_to_author(author, documents)
    token = create_access_token(author, documents)
    DocumentMailer.send_access_link(author, token).deliver_later
  end

  def create_access_token(author, documents)
    author.author_access_tokens.create!(
      document_ids: documents.map(&:id)
    )
  end
end
