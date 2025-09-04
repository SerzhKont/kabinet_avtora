class ReplaceClientIdWithAuthorIdInDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :documents, :users, column: :client_id
    remove_index :documents, name: :index_documents_on_client_id
    remove_column :documents, :client_id, :integer
    add_column :documents, :author_id, :integer
    add_index :documents, :author_id, name: :index_documents_on_author_id
    add_foreign_key :documents, :authors, column: :author_id
  end
end
