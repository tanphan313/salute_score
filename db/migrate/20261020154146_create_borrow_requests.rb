class CreateBorrowRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :borrow_requests do |t|
      t.bigint  :borrower_id
      t.decimal :amount, precision: 40, scale: 24
      t.string  :token_symbol, default: "SLT"
      t.decimal :proposed_interest_rate, precision: 5, scale: 2
      t.integer :duration_in_days

      t.integer  :status, default: 0
      t.datetime :locked_until
      t.datetime :funded_at
      t.integer :funded_amount

      t.timestamps
    end

    add_index :borrow_requests, :borrower_id
    add_index :borrow_requests, :status

    create_table :borrow_request_lenders do |t|
      t.bigint  :borrow_request_id
      t.bigint  :lender_id
      t.integer :status, default: 0
      t.datetime :locked_until

      t.timestamps
    end

    add_index :borrow_request_lenders, :borrow_request_id
    add_index :borrow_request_lenders, :lender_id
  end
end
