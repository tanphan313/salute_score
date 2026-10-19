class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.integer :max_lending_interest_rate, default: 0

      t.timestamps
    end

    add_index :countries, :code, unique: true
    add_index :countries, :name, unique: true
  end
end
