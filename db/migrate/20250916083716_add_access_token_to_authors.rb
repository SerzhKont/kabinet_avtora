class AddAccessTokenToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :access_token, :string
    add_column :authors, :access_token_expires_at, :datetime
    add_index :authors, :access_token, unique: true
  end
end
