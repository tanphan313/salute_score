class ProfilesController < ApplicationController
  def show
    xaman_client = Xaman::Client.new
    xaman_info = xaman_client.get_account_info(current_user.address) || xaman_client.get_xrpl_account_info(current_user.address)

    render_success(
      data: {
        user: user_payload(current_user),
        xaman_account_info: xaman_info
      },
      message: "Profile retrieved successfully"
    )
  end

  def update
    if current_user.update(profile_params)
      render_success(
        data: {
          user: user_payload(current_user)
        },
        message: "Profile updated successfully"
      )
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
    params.require(:profile).permit(:country_id, :phone_number, :name, :email)
  end

  def user_payload(user)
    {
      id: user.id,
      address: user.address,
      user_token: user.user_token,
      name: user.name,
      email: user.email,
      phone_number: user.phone_number,
      avatar_url: user.avatar_url,
      country: user.country ? {
        id: user.country.id,
        code: user.country.code,
        name: user.country.name,
        max_lending_interest_rate: user.country.max_lending_interest_rate
      } : nil
    }
  end
end
