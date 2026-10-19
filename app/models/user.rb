class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  belongs_to :country, optional: true

  validates :address, presence: true, uniqueness: true
  validates :name, uniqueness: true, allow_nil: true
  validates :phone_number, uniqueness: true, allow_nil: true
  validates :email, uniqueness: true, allow_nil: true

  def email_required?
    false
  end

  def password_required?
    false
  end
end
