class AddSignedAtToDocumentGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :document_groups, :signed_at, :datetime
  end
end
