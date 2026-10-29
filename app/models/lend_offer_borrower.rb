class LendOfferBorrower < ApplicationRecord
  belongs_to :lend_offer
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id"
  has_one :token_rate, through: :lend_offer
  has_one :loan, dependent: :destroy

  enum :status, %i[locking funded cancelled]

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :duration_in_days, presence: true

  validate :validate_borrower_tier_and_verification, on: :create
  validate :validate_duration_in_allowed_days, on: :create
  validate :validate_amount_within_offer_limits, on: :create

  delegate :interest_rate, to: :lend_offer

  def interest_amount
    return 0 if amount.nil? || interest_rate.nil?

    amount * (interest_rate / 100.0)
  end

  def total_lender_receive_amount
    return 0 if amount.nil?

    amount + interest_amount
  end

  def salute_fee
    return 0 if amount.nil?

    rate = pay_salute_fee_in_slt ? 0.375 : 0.5
    amount * (rate / 100.0)
  end

  def total_borrower_repayment_amount
    return 0 if amount.nil?

    total_lender_receive_amount + salute_fee
  end

  private
  def validate_borrower_tier_and_verification
    return if borrower.blank? || lend_offer.blank?

    borrower_tier = User.ranking_levels[borrower.ranking_level] || 0
    required_tier = User.ranking_levels[lend_offer.lowest_tier] || 0
    if borrower_tier < required_tier
      errors.add(:borrower, "does not meet the required minimum tier level")
    end

    borrower_verification = User.verification_levels[borrower.verification_level] || 0
    required_verification = User.verification_levels[lend_offer.required_verification_level] || 0
    if borrower_verification < required_verification
      errors.add(:borrower, "does not meet the required verification level")
    end
  end

  def validate_duration_in_allowed_days
    unless lend_offer&.allowed_duration_days&.include?(duration_in_days.to_i)
      errors.add(:duration_in_days, "is not supported by this lend offer (allowed: #{lend_offer&.allowed_duration_days&.join(', ')})")
    end
  end

  def validate_amount_within_offer_limits
    return if lend_offer.blank? || amount.blank?

    if amount < lend_offer.min_loan_amount
      errors.add(:amount, "is below minimum loan limit ($#{lend_offer.min_loan_amount})")
    end

    if amount > lend_offer.max_loan_amount
      errors.add(:amount, "exceeds maximum loan limit per order ($#{lend_offer.max_loan_amount})")
    end

    available_amount = lend_offer.available_amount
    if amount > available_amount
      errors.add(:amount, "exceeds remaining available lend amount ($#{available_amount})")
    end
  end
end
