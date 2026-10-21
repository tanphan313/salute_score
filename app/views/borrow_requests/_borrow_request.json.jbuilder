json.(borrow_request,
  :id,
  :borrower_id,
  :token_rate_id,
  :amount,
  :proposed_interest_rate,
  :duration_in_days,
  :status,
  :created_at,
  :interest_amount,
  :salute_interest_amount,
  :total_repayment_amount,
  :repay_by_date
)

json.token_rate do
  json.(borrow_request.token_rate, :id, :symbol, :price_in_cents)
end

json.borrower do
  json.(borrow_request.borrower, :id, :score, :verification_level, :ranking_level, :name, :avatar_url)
end
