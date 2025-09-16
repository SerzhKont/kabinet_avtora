class AddFileHashAndSignedDataToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :file_hash, :string
    add_column :documents, :signed_data, :text
  end
end
