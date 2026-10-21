json.(lend_offer,
  :id,
  :lender_id,
  :token_rate_id,
  :total_amount,
  :min_loan_amount,
  :max_loan_amount,
  :interest_rate,
  :allowed_duration_days,
  :lowest_tier,
  :required_verification_level,
  :status,
  :created_at
)

json.token_rate do
  json.(lend_offer.token_rate, :id, :symbol, :price_in_cents)
end

json.lender do
  json.(lend_offer.lender, :id, :score, :verification_level, :ranking_level, :name, :avatar_url)
end
