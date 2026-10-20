class BorrowRequestLender < ApplicationRecord
  belongs_to :borrow_request, optional: true
  belongs_to :lender, class_name: "User", foreign_key: "lender_id", optional: true

  enum :status, %i[locking completed released], prefix: true
end
