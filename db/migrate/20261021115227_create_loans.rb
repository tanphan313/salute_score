class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.bigint :borrower_id
      t.bigint :lender_id
      t.references :borrow_request_lender, foreign_key: true
      t.references :lend_offer_borrower, foreign_key: true
      t.references :token_rate, foreign_key: true

      t.decimal :amount, precision: 40, scale: 24
      t.decimal :interest_rate, precision: 5, scale: 2
      t.integer :funded_amount # in cents
      t.integer :duration_in_days
      t.datetime :funded_at
      t.datetime :due_at
      t.datetime :repaid_at
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
