json.(borrow_request,
  :id,
  :borrower_id,
  :token_symbol,
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

json.borrower do
  json.(borrow_request.borrower, :id, :score, :verification_level, :ranking_level, :name, :avatar_url)
end
