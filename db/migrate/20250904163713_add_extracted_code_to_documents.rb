class AddExtractedCodeToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :extracted_code, :string
    add_index :documents, :extracted_code
  end
end
