class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :email_address
      t.integer :code

      t.timestamps
    end

    add_index :authors, :code, unique: true
  end
end
