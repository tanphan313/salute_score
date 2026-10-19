class ProfilesController < ApplicationController
  def show
    xaman_client = Xaman::Client.new
    xaman_info = xaman_client.get_account_info(current_user.address)

    render_success(
      data: {
        user: {
          id: current_user.id,
          address: current_user.address,
          user_token: current_user.user_token,
          name: current_user.name,
          avatar_url: current_user.avatar_url
        },
        xaman_account_info: xaman_info
      },
      message: "Profile retrieved successfully"
    )
  end
end
