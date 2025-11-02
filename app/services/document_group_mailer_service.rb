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

      # Обновляем статус документов на "pending" и устанавливаем дату отправки
      documents_to_group.update_all(status: NEW_STATUS_AFTER_SEND, sent_for_signature_at: Time.current)
      Rails.logger.info "Обновлен статус #{documents_to_group.count} документов на '#{NEW_STATUS_AFTER_SEND}'"
      Rails.logger.info "Установлена дата отправки на подпись для #{documents_to_group.count} документов"
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Ошибка при отправке группы документов: #{e.message}"
  end
end
