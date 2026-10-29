class TokenRate < ApplicationRecord
  validates :symbol, presence: true, uniqueness: { case_sensitive: false }
  validates :price_in_cents, presence: true, numericality: { greater_than: 0 }
  validates :issuer_address, presence: true, unless: -> { symbol.to_s.upcase == "XRP" }

  def to_cents(token_amount)
    return 0 if price_in_cents.nil? || token_amount.blank?

    (token_amount.to_f * price_in_cents).round
  end

  def from_cents(cents_amount)
    return 0.0 if price_in_cents.nil? || price_in_cents.zero? || cents_amount.blank?

    (cents_amount.to_f / price_in_cents).round(4)
  end
end
