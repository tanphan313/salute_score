class XamanAuthController < ApplicationController
  skip_before_action :authenticate_user!

  SIGNIN_TOKEN_PREFIX = "xaman_signin:"
  SIGNIN_TOKEN_TTL = 5.minutes

  def request_signin
    payload_data = XamanService::CreateSignin.call

    unless payload_data[:success] && payload_data[:data][:uuid].present?
      return render_error(
        message: "Failed to create Xaman payload",
        status: :unprocessable_entity
      )
    end

    signin_token = SecureRandom.hex(32)

    Rails.cache.write(
      "#{SIGNIN_TOKEN_PREFIX}#{signin_token}",
      payload_data[:data][:uuid],
      expires_in: SIGNIN_TOKEN_TTL
    )

    response.headers["X-Signin-Token"] = signin_token

    render_success(
      data: payload_data[:data],
      message: "SignIn payload created successfully"
    )
  end

  def verify_signin
    signin_token = request.headers["X-Signin-Token"]

    if signin_token.blank?
      return render_error(
        message: "Missing X-Signin-Token header",
        status: :bad_request
      )
    end

    cache_key = "#{SIGNIN_TOKEN_PREFIX}#{signin_token}"
    payload_uuid = Rails.cache.read(cache_key)

    if payload_uuid.blank?
      return render_error(
        message: "Invalid or expired signin session",
        status: :unauthorized
      )
    end

    xaman_data = XamanService::VerifySignin.call(uuid: payload_uuid)

    unless xaman_data[:success] && xaman_data[:data][:account].present?
      return render_error(
        message: "Payload not signed yet or verification failed",
        status: :unauthorized
      )
    end

    address = xaman_data[:data][:account]
    account_info = Xaman.client.accounts.find(address)

    user = User.find_or_initialize_by(address: address)
    is_new_user = user.new_record?

    attributes = {
      uid: address,
      provider: "xaman",
      name: xaman_data[:data][:name].presence || user.name,
      user_token: xaman_data[:data][:user_token],
      avatar_url: account_info.dig(:data, "avatar").presence || user.avatar_url
    }

    unless user.update(attributes)
      return render_error(
        message: user.errors.full_messages.to_sentence,
        status: :unprocessable_entity
      )
    end

    Rails.cache.delete(cache_key)

    auth_headers = user.create_new_auth_token
    response.headers.merge!(auth_headers)

    render_success(
      data: {
        is_new_user: is_new_user,
        id: user.id,
        address: user.address,
        name: user.name,
        avatar_url: user.avatar_url
      },
      message: is_new_user ? "Account created. Profile setup required." : "Signed in successfully"
    )
  end
end
