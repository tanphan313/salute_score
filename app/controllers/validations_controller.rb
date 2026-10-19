class ValidationsController < ApplicationController
  def check_uniqueness
    attribute = validation_params[:attribute]
    value = validation_params[:value]&.strip

    unless %w[name email phone_number].include?(attribute)
      return render_error(
        message: "Invalid attribute. Only name, email, and phone_number are supported.",
        status: :bad_request
      )
    end

    if value.blank?
      return render_error(message: "Value cannot be blank", status: :bad_request)
    end

    query = User.where("LOWER(#{attribute}) = ?", value.downcase)
    query = query.where.not(id: current_user.id) if current_user.present?

    is_taken = query.exists?

    render_success(
      data: {
        attribute: attribute,
        value: value,
        available: !is_taken
      },
      message: is_taken ? "#{attribute.capitalize} is already taken" : "#{attribute.capitalize} is available"
    )
  end

  private
  def validation_params
    params.require(:validation).permit(:attribute, :value)
  end
end
