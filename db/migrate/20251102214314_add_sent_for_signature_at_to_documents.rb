class AddSentForSignatureAtToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :sent_for_signature_at, :datetime
  end
end
