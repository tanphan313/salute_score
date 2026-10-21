module Me
  class BorrowRequestsController < ApplicationController
    SORT_COLUMN = {
      created_at: "created_at",
      amount: "amount",
      interest: "order_by_interest"
    }.with_indifferent_access.freeze

    def index
      scope = current_user.borrow_requests.includes(:borrower)
      scope = scope.where(status: params[:status]) if params[:status].present?
      if (params[:from_date].present? || params[:to_date].present?) && params[:status] == "repaid"
        scope = scope.repaid_between(params[:from_date], params[:to_date])
      end

      ransack_search = scope.ransack({})
      ransack_search.sorts = order_str

      @borrow_requests = ransack_search.result.page(params[:page]).per(params[:per_page] || 20)

      render :index
    end

    def show
      @borrow_request = current_user.borrow_requests.find(params[:id])
    end

    private
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
end
