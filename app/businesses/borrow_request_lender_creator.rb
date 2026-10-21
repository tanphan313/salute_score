class BorrowRequestLenderCreator
  attr_reader :borrow_request, :lender, :borrower, :token_rate

  def initialize borrow_request:, lender:
    @borrow_request = borrow_request
    @lender = lender
    @borrower = borrow_request.borrower
    @token_rate = borrow_request.token_rate
  end

  def create!
    ApplicationRecord.transaction  do
      borrow_request.locked!
      create_borrow_request_lender!
      transfer_token!
    end
  end

  private
  def create_borrow_request_lender!
    BorrowRequestLender.create!(
      borrow_request: borrow_request,
      lender: lender,
      locked_until: 5.minutes.from_now
    )
  end

  def transfer_token!
    XamanService::CreatePayment.(
      sender_address: lender.address,
      receiver_address: borrower.address,
      amount: borrow_request.amount,
      token_rate: token_rate,
      user_token: lender.user_token
    )
  end
end
