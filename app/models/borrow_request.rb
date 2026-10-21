class BorrowRequest < ApplicationRecord
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id"
  has_many :borrow_request_lenders

  DURATIONS = {
    days_7: 7,
    days_14: 14,
    days_30: 30,
    days_60: 60,
    days_90: 90
  }.freeze

  enum :duration_in_days, DURATIONS, prefix: :duration
  enum :status, %i[pending locked funded cancelled expired repaid]

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :proposed_interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_in_days, :token_symbol, presence: true
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

    relation = all
    relation = relation.where("repaid_at >= ?", from_time) if from_time
    relation = relation.where("repaid_at <= ?", to_time) if to_time
    relation
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id borrower_id token_symbol amount proposed_interest_rate duration_in_days status created_at repaid_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[borrower]
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[order_by_interest order_by_borrower_score]
  end

  def interest_amount
    return 0 if amount.nil? || proposed_interest_rate.nil?

    (amount * (proposed_interest_rate || 0.0) / 100.0)
  end

  def salute_interest_amount
    return 0 if amount.nil?

    ((amount * 0.5) / 100.0)
  end

  def total_repayment_amount
    return 0 if amount.nil?

    amount + interest_amount + salute_interest_amount
  end

  def repay_by_date(from_date = Time.current)
    due_date || (from_date + duration_in_days.to_i.days if duration_in_days.present?)
  end

  def due_date
    return nil if funded_at.nil? || duration_in_days.blank?

    funded_at + duration_in_days.to_i.days
  end

  def overdue?
    return false unless funded? && due_date.present?

    Time.current > due_date
  end

  def repaid_on_time?
    return false unless repaid? && repaid_at.present? && due_date.present?

    repaid_at <= due_date
  end

  def days_overdue
    target_time = repaid_at || Time.current
    return 0 if due_date.nil? || target_time <= due_date

    ((target_time - due_date) / 1.day).ceil
  end

  def mark_as_repaid!
    return false unless funded?

    update!(
      status: :repaid,
      repaid_at: Time.current
    )
  end

  def formatted_repay_by_date(format = "%d/%m/%Y")
    date = repay_by_date
    date&.strftime(format)
  end

  private
  def validate_borrower_limit
    current_token_rate = TokenRate.find_by(symbol: token_symbol)
    if current_token_rate.nil?
      errors.add(:token_symbol, "is invalid or missing exchange rate")
      return
    end

    new_request_amount = (amount * (current_token_rate.price_in_cents || 0.0)).round
    current_funded_amount = borrower.borrow_requests.funded.sum(:funded_amount)
    active_pending_cents = borrower.borrow_requests
      .active
      .joins("INNER JOIN token_rates ON token_rates.symbol = borrow_requests.token_symbol")
      .sum(Arel.sql("ROUND(borrow_requests.amount * token_rates.price_in_cents)"))
      .to_i

    total_requested_cents = current_funded_amount + active_pending_cents + new_request_amount
    max_limit_in_cents = borrower.max_borrowing_amount

    if total_requested_cents > max_limit_in_cents
      remaining_limit_cents = [max_limit_in_cents - (current_funded_amount + active_pending_cents), 0].max
      remaining_limit_usd = (remaining_limit_cents / 100.0).round(2)

      errors.add(:amount, "exceeds your remaining borrowing limit ($#{remaining_limit_usd} USD available)")
    end
  end
end
