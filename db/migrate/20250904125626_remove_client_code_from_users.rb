class RemoveClientCodeFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, name: :index_users_on_client_code
    remove_column :users, :client_code, :string
  end
end
