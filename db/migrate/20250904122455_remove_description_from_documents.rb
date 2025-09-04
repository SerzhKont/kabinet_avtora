class RemoveDescriptionFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :description, :text
  end
end
