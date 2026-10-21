class CreateLendOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :lend_offers do |t|
      t.bigint  :lender_id
      t.references  :token_rate, foreign_key: true, index: true

      t.decimal :total_amount, precision: 40, scale: 24
      t.decimal :min_loan_amount, precision: 40, scale: 24
      t.decimal :max_loan_amount, precision: 40, scale: 24
      t.decimal :interest_rate, precision: 5, scale: 2, default: 0.0

      t.integer :allowed_duration_days, array: true, default: []

      t.integer :lowest_tier, default: 0
      t.integer :required_verification_level, default: 0

      t.integer :status, default: 0

      t.timestamps
    end

    add_index :lend_offers, :lender_id
    add_index :lend_offers, :status
  end
end
