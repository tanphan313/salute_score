class RemoveFundingFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :borrow_requests, :funded_amount, :integer
    remove_column :borrow_requests, :funded_at, :datetime
    remove_column :borrow_requests, :repaid_at, :datetime

    remove_column :lend_offer_borrowers, :funded_amount, :integer
    remove_column :lend_offer_borrowers, :funded_at, :datetime
    remove_column :lend_offer_borrowers, :repaid_at, :datetime
  end
end
