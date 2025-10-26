class RemoveColumnsFromAuthors < ActiveRecord::Migration[8.0]
  def change
    remove_column :authors, :access_token
    remove_column :authors, :access_token_expires_at
  end
end
