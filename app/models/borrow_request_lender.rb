class BorrowRequestLender < ApplicationRecord
  belongs_to :borrow_request, optional: true
  belongs_to :lender, class_name: "User", foreign_key: "lender_id", optional: true
  has_one :loan, dependent: :destroy

  enum :status, %i[locking completed released]

  validate :only_one_completed_lender_per_borrow_request

  private
  def only_one_completed_lender_per_borrow_request
    return if borrow_request_id.blank?
    return unless completed?

    scope = self.class.completed.where(borrow_request_id: borrow_request_id)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:status, "One borrow request can only have one completed lender")
    end
  end
end
