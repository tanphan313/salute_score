class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  protected

  def render_success(data: {}, message: "Success", status: :ok)
    render json: { success: true, message: message, data: data }, status: status
  end

  def render_error(message: "An error occurred", status: :bad_request, errors: [])
    render json: { success: false, message: message, errors: errors }, status: status
  end

  private

  def render_not_found
    render_error(message: "Resource not found", status: :not_found)
  end

  def render_unprocessable_entity(exception)
    render_error(
      message: "Unprocessable entity",
      status: :unprocessable_entity,
      errors: exception.record.errors.full_messages
    )
  end
end
