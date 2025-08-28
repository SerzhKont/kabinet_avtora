class AddIndexesToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_index :documents, :status unless index_exists?(:documents, :status)
    add_index :documents, :signed_at unless index_exists?(:documents, :signed_at)
  end
end
