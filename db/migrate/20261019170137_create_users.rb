class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Devise Token Auth Core Required Fields
      t.string :provider, default: "xaman"
      t.string :uid, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.json :tokens

      t.string :address, null: false         # Public Address (account)
      t.string :user_token
      t.string :name
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :address, unique: true
    add_index :users, [:uid, :provider], unique: true
  end
end
