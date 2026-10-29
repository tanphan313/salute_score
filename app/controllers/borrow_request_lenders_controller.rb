class BorrowRequestLendersController < ApplicationController
  def create
    borrow_request_lender_creator = BorrowRequestLenderCreator.new(
      borrow_request: borrow_request,
      lender: current_user
    )

    ResultMonad.new do
      borrow_request_lender_creator.create!
    end.then do
      @message = "Borrow request lender created successfully"
      @borrow_request_lender = borrow_request_lender_creator.borrow_request_lender
      @payment_payload = borrow_request_lender_creator.payment_payload
      render :create, status: :created
    end.rescue do |e|
      render_error(
        message: "Create failed",
        status: :unprocessable_entity,
        errors: e.message.split(", ")
      )
    end
  end

  private
  def borrow_request
    @borrow_request ||= BorrowRequest.find(params[:borrow_request_id])
  end
end
