class AddRepaidAtToBorrowRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :borrow_requests, :repaid_at, :datetime
  end
end
