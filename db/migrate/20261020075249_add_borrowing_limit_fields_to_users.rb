class AddBorrowingLimitFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :custom_max_borrowing_amount, :integer
  end
end
