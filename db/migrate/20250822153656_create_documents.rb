class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :description
      t.string :status
      t.references :client, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: true
      t.datetime :signed_at

      t.timestamps
    end
  end
end
