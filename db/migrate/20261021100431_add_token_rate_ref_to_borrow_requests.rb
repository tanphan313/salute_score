class AddTokenRateRefToBorrowRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :borrow_requests, :token_rate, foreign_key: true, index: true
    remove_column :borrow_requests, :token_symbol, :string, default: "SLT"
  end
end
