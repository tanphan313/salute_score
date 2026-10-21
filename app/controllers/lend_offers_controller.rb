class LendOffersController < ApplicationController
  CREATE_PARAMS = [
    :token_rate_id,
    :total_amount,
    :min_loan_amount,
    :max_loan_amount,
    :interest_rate,
    :lowest_tier,
    :required_verification_level,
    { allowed_duration_days: [] }
  ].freeze

  SORT_COLUMN = {
    created_at: "created_at",
    total_amount: "total_amount",
    interest_rate: "order_by_interest"
  }.with_indifferent_access.freeze

  def index
    ransack_search = LendOffer.active.includes(:lender).ransack({})
    ransack_search.sorts = order_str

    @lend_offers = ransack_search.result.page(params[:page]).per(params[:per_page] || 20)
  end

  def create
    @lend_offer = current_user.lend_offers.build(lend_offer_params)

    if @lend_offer.save
      @message = "Lend offer created successfully"

      render :create, status: :created
    else
      render_error(
        message: "Validation failed",
        status: :unprocessable_entity,
        errors: @lend_offer.errors.full_messages
      )
    end
  end

  private
  def lend_offer_params
    params.require(:lend_offer).permit(CREATE_PARAMS)
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
