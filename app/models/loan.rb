class Loan < ApplicationRecord
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id", inverse_of: :borrowed_loans
  belongs_to :lender, class_name: "User", foreign_key: "lender_id", inverse_of: :lent_loans
  belongs_to :borrow_request_lender, optional: true
  belongs_to :lend_offer_borrower, optional: true
  belongs_to :token_rate

  enum :status, %i[active repaid late]

  validates :amount, numericality: { greater_than: 0 }
  validates :funded_amount, numericality: { greater_than: 0 }
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_in_days, numericality: { only_integer: true, greater_than: 0 }
  validates :due_at, comparison: { greater_than: :funded_at }
  validates :repaid_at, presence: true, if: :repaid?
  validates :borrow_request_lender, presence: true, unless: -> { lend_offer_borrower.present? }
  validates :lend_offer_borrower, presence: true, unless: -> { borrow_request_lender.present? }
  validate :exactly_one_source

  scope :borrowing_by, ->(user_id) { where(borrower_id: user_id) }
  scope :lending_by, ->(user_id) { where(lender_id: user_id) }

  private
  def exactly_one_source
    if borrow_request_lender.present? == lend_offer_borrower.present?
      errors.add(:base, "Must have exactly one loan source")
    end
  end
end
