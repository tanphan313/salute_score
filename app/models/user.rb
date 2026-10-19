class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  validates :address, presence: true, uniqueness: true

  def email_required?
    false
  end

  def password_required?
    false
  end
end
