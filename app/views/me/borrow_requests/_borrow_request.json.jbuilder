json.(borrow_request,
  :id,
  :borrower_id,
  :token_symbol,
  :amount,
  :proposed_interest_rate,
  :duration_in_days,
  :status,
  :created_at,
  :locked_until,
  :funded_at,
  :funded_amount,
  :repaid_at,
  :interest_amount,
  :salute_interest_amount,
  :total_repayment_amount
)

json.due_date borrow_request.due_date
json.is_overdue borrow_request.overdue?
json.is_repaid_on_time borrow_request.repaid_on_time?
json.days_overdue borrow_request.days_overdue
