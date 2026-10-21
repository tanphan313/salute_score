class ProfilesController < ApplicationController
  UPDATE_PARAMS = %i[country_id phone_number name email].freeze

  def show
    @xaman_info = Xaman.client.accounts.find(current_user.address)

    @message = "Profile retrieved successfully"
    render :show
  end

  def update
    if current_user.update(profile_params)
      @message = "Profile updated successfully"

      render :update
    else
      render_error(
        message: "Validation failed",
        status: :unprocessable_entity,
        errors: current_user.errors.full_messages
      )
    end
  end

  private
  def profile_params
    params.require(:profile).permit(UPDATE_PARAMS)
  end
end
