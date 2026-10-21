class LendOffer < ApplicationRecord
  belongs_to :lender, class_name: "User", foreign_key: "lender_id"
  belongs_to :token_rate

  has_many :lend_offer_borrowers, dependent: :destroy

  ALLOWED_DURATIONS = [7, 14, 30, 60, 90].freeze

  enum :status, %i[pending partial_fulfilled fulfilled cancelled]

  enum :lowest_tier, User.ranking_levels, prefix: :tier
  enum :required_verification_level, User.verification_levels, prefix: :verification

  validates :token_symbol, :total_amount, :min_loan_amount, :max_loan_amount, presence: true
  validates :total_amount, :min_loan_amount, :max_loan_amount, numericality: { greater_than: 0 }
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_loan_amounts
  validate :validate_allowed_duration_days

  before_validation :apply_country_interest_rate_limit, on: :create

  scope :order_by_interest, ->(direction = :desc) {
    select("lend_offers.*, (lend_offers.amount * lend_offers.interest_rate) AS calculated_interest")
      .order(Arel.sql("(lend_offers.amount * lend_offers.interest_rate) #{direction.to_s.upcase}"))
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id lender_id token_rate_id total_amount interest_rate allowed_duration_days status created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[lender token_rate]
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[order_by_interest]
  end

  def total_borrowed_amount
    lend_offer_borrowers.where(status: %i[funded repaid]).sum(:amount)
  end

  def available_amount
    [total_amount - (total_borrowed_amount || 0.0), 0].max
  end

  private
  def validate_loan_amounts
    return if min_loan_amount.blank? || max_loan_amount.blank? || total_amount.blank?

    if min_loan_amount > max_loan_amount
      errors.add(:min_loan_amount, "cannot be greater than maximum loan amount")
    end

    if max_loan_amount > total_amount
      errors.add(:max_loan_amount, "cannot exceed total amount available to lend")
    end
  end

  def validate_allowed_duration_days
    if allowed_duration_days.blank?
      errors.add(:allowed_duration_days, "must select at least one duration")
      return
    end

    invalid_durations = allowed_duration_days.to_a - ALLOWED_DURATIONS
    if invalid_durations.any?
      errors.add(:allowed_duration_days, "contains invalid durations: #{invalid_durations.join(', ')}")
    end
  end

  def apply_country_interest_rate_limit
    return unless lender&.country.present?

    if self.interest_rate >= lender.country.max_lending_interest_rate.to_f
      self.interest_rate = lender.country.max_lending_interest_rate.to_f
    end
  end
end
