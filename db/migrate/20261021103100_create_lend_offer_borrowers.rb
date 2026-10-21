class CreateLendOfferBorrowers < ActiveRecord::Migration[8.1]
  def change
    create_table :lend_offer_borrowers do |t|
      t.bigint  :lend_offer_id
      t.bigint  :borrower_id

      t.decimal :amount, precision: 40, scale: 24
      t.integer :duration_in_days

      t.boolean :pay_salute_fee_in_slt, default: false
      t.integer :status, default: 0

      t.datetime :funded_at
      t.integer :funded_amount # in cents
      t.datetime :repaid_at

      t.timestamps
    end

    add_index :lend_offer_borrowers, :lend_offer_id
    add_index :lend_offer_borrowers, :borrower_id
    add_index :lend_offer_borrowers, :status
  end
end
