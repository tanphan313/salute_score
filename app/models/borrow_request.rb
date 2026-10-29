class BorrowRequest < ApplicationRecord
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id"
  belongs_to :token_rate

  has_many :borrow_request_lenders, dependent: :destroy
  has_many :loans, through: :borrow_request_lenders

  DURATIONS = {
    days_7: 7,
    days_14: 14,
    days_30: 30,
    days_60: 60,
    days_90: 90
  }.freeze

  enum :duration_in_days, DURATIONS, prefix: :duration
  enum :status, [:pending, :locked, :funded, :cancelled]

  def duration_in_days=(val)
    val = val.to_i if val.is_a?(String) && val =~ /\A\d+\z/
    super(val)
  end

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :proposed_interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_in_days, :token_rate_id, presence: true
  validate  :validate_borrower_limit, on: :create

  scope :order_by_interest, ->(direction = :desc) {
    select("borrow_requests.*, (borrow_requests.amount * borrow_requests.proposed_interest_rate) AS calculated_interest")
      .order(Arel.sql("(borrow_requests.amount * borrow_requests.proposed_interest_rate) #{direction.to_s.upcase}"))
  }
  scope :order_by_borrower_score, ->(direction = :desc) {
    joins(:borrower).order("users.score #{direction.to_s.upcase}")
  }
  scope :active, -> { where(status: %i[pending locked]) }
  scope :repaid_between, ->(from_date, to_date) {
    from_time = Time.zone.parse(from_date.to_s).beginning_of_day rescue nil
    to_time   = Time.zone.parse(to_date.to_s).end_of_day rescue nil

    relation = joins(:loans)
    relation = relation.where("loans.repaid_at >= ?", from_time) if from_time
    relation = relation.where("loans.repaid_at <= ?", to_time) if to_time
    relation
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id borrower_id token_rate_id amount proposed_interest_rate duration_in_days status created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[borrower token_rate loans]
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[order_by_interest order_by_borrower_score repaid_between]
  end

  def interest_amount
    return 0 if amount.nil? || proposed_interest_rate.nil?

    (amount.to_d * proposed_interest_rate.to_d / 100.0)
  end

  def salute_interest_amount
    return 0 if amount.nil?

    (amount.to_d * BigDecimal("0.5") / 100.0)
  end

  def total_repayment_amount
    return 0 if amount.nil?

    amount.to_d + interest_amount + salute_interest_amount
  end

  private
  def validate_borrower_limit
    return if token_rate.nil? || borrower.nil?

    new_request_amount = (amount.to_f * (token_rate.price_in_cents || 0.0)).round

    current_funded_cents = borrower.borrowed_loans
      .active
      .joins(:token_rate)
      .sum(Arel.sql("ROUND(loans.amount * token_rates.price_in_cents)"))
      .to_i

    active_pending_cents = borrower.borrow_requests
      .active
      .joins(:token_rate)
      .sum(Arel.sql("ROUND(borrow_requests.amount * token_rates.price_in_cents)"))
      .to_i

    total_requested_cents = current_funded_cents + active_pending_cents + new_request_amount
    max_limit_in_cents = borrower.max_borrowing_amount

    if total_requested_cents > max_limit_in_cents
      remaining_limit_cents = [max_limit_in_cents - (current_funded_cents + active_pending_cents), 0].max
      remaining_limit_usd = (remaining_limit_cents / 100.0).round(2)

      errors.add(:amount, "exceeds your remaining borrowing limit ($#{remaining_limit_usd} USD available)")
    end
  end
end
