json.success true
json.message @message ||= "Borrow request lender created successfully"

json.data do
  if @borrow_request_lender.present?
    json.borrow_request_lender do
      json.extract! @borrow_request_lender, :id, :borrow_request_id, :lender_id, :status, :locked_until, :created_at
    end
  end

  if @payment_payload.present?
    json.payment_payload @payment_payload
  end
end
