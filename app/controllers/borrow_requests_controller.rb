class BorrowRequestsController < ApplicationController
  CREATE_PARAMS = %i[amount token_symbol proposed_interest_rate duration_in_days].freeze

  SORT_COLUMN = {
    created_at: "created_at",
    amount: "amount",
    interest: "order_by_interest",
    score: "order_by_borrower_score"
  }.with_indifferent_access.freeze

  def index
    ransack_search = BorrowRequest.pending.includes(:borrower).ransack({})
    ransack_search.sorts = order_str

    @borrow_requests = ransack_search.result.page(params[:page]).per(params[:per_page] || 20)
  end

  def create
    @borrow_request = current_user.borrow_requests.build(borrow_request_params)

    if @borrow_request.save
      @message = "Borrow request created successfully"

      render :create, status: :created
    else
      render_error(
        message: "Validation failed",
        status: :unprocessable_entity,
        errors: @borrow_request.errors.full_messages
      )
    end
  end

  private
  def borrow_request_params
    params.require(:borrow_request).permit(CREATE_PARAMS)
  end

  def sort_column
    SORT_COLUMN[params[:sort]] || SORT_COLUMN[:created_at]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction].to_s.downcase) ? params[:direction] : "desc"
  end

  def order_str
    "#{sort_column} #{sort_direction}"
  end
end
