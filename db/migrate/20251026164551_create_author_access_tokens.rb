class CreateAuthorAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :author_access_tokens do |t|
      t.references :author, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at
      t.text :document_ids

      t.timestamps
    end
    add_index :author_access_tokens, :token, unique: true
    add_index :author_access_tokens, :expires_at
  end
end
