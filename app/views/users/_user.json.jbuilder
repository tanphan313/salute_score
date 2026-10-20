json.extract! user,
  :id,
  :address,
  :user_token,
  :name,
  :email,
  :phone_number,
  :avatar_url,
  :verification_level,
  :ranking_level

json.max_borrowing_amount user.max_borrowing_amount

json.country do
  json.partial! "countries/country", country: user.country
end
