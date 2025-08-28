class ImproveDocumentsStructure < ActiveRecord::Migration[8.0]
  def change
    # Исправляем существующие проблемы
    remove_foreign_key :documents, :clients if foreign_key_exists?(:documents, :clients)
    remove_column :documents, :client_id if column_exists?(:documents, :client_id)  # Если ещё не удалили

    # Добавляем client_id как foreign key на users
    add_column :documents, :client_id, :integer
    add_index :documents, :client_id unless index_exists?(:documents, :client_id)
    add_foreign_key :documents, :users, column: :client_id

    # Исправляем uploaded_by_id
    add_foreign_key :documents, :users, column: :uploaded_by_id
  end
end
