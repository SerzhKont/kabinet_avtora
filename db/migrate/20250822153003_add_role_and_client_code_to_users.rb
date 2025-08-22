class AddRoleAndClientCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, null: false, default: 'client'
    add_column :users, :client_code, :string
    add_column :users, :name, :string
    add_index :users, :role
    add_index :users, :client_code, unique: true
  end
end
