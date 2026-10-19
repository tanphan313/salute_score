class Country < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :max_lending_interest_rate, numericality: { greater_than_or_equal_to: 0 }

  def max_lending_rate_decimal
    max_lending_interest_rate / 100.0
  end
end
