class DocumentGroupMailerService
  MAX_DOCS_PER_GROUP = 7
  NEW_STATUS_AFTER_SEND = "pending"

  def self.call(document_ids)
    documents_to_group = Document.where(id: document_ids)
                                  .where(status: "linked")
                                  .where.not(author_id: nil)

    return if documents_to_group.empty?

    ActiveRecord::Base.transaction do
      docs_by_author = documents_to_group.group_by(&:author_id)

      docs_by_author.each do |author_id, documents|
        author = Author.find_by(id: author_id)
        next unless author&.email_address.present?

        document_chunks = documents.in_groups_of(MAX_DOCS_PER_GROUP, false)

        document_chunks.each do |chunk|
          document_ids = chunk.map(&:id)

          group = DocumentGroup.create!(
            author: author,
            document_ids: document_ids
          )

          # AuthorMailer.send_document_group_link(group).deliver_later
          AuthorMailer.send_document_group_link(group).deliver_now
        end
      end
      documents_to_group.update_all(status: NEW_STATUS_AFTER_SEND)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Ошибка при отправке группы документов: #{e.message}"
  end
end
