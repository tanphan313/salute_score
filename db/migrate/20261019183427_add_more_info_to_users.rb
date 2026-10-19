class AddMoreInfoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :email, :string
    add_reference :users, :country

    add_index :users, :name
    add_index :users, :email
    add_index :users, :phone_number
  end
end
