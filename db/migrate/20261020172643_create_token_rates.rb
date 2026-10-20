class CreateTokenRates < ActiveRecord::Migration[8.1]
  def change
    create_table :token_rates do |t|
      t.string  :symbol, null: false
      t.string  :name
      t.integer :price_in_cents, default: 0

      t.timestamps
    end

    add_index :token_rates, :symbol, unique: true
  end
end
