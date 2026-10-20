class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  MAX_BORROWING_LIMITS_IN_CENTS = {
    "wallet"   => 25_00,
    "phone"    => 300_00,
    "id_check" => 5_000_00,
    "income"   => 25_000_00
  }.freeze

  enum :verification_level, %i(wallet phone id_check income), prefix: true
  enum :ranking_level, %i(bronze silver gold platinum), prefix: true

  belongs_to :country, optional: true

  has_many :borrow_requests, foreign_key: "borrower_id", dependent: :destroy
  has_many :borrow_request_lenders, foreign_key: "lender_id", dependent: :destroy

  validates :address, presence: true, uniqueness: true
  validates :name, uniqueness: true, allow_nil: true
  validates :phone_number, uniqueness: true, allow_nil: true
  validates :email, uniqueness: true, allow_nil: true

  def default_max_borrowing_amount
    MAX_BORROWING_LIMITS_IN_CENTS.fetch(verification_level || :wallet, 0)
  end

  def max_borrowing_amount
    custom_max_borrowing_amount || default_max_borrowing_amount
  end

  def override_borrowing_limit!(new_limit)
    update!(custom_max_borrowing_amount: new_limit)
  end

  def email_required?
    false
  end

  def password_required?
    false
  end
end
