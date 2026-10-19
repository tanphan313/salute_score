class XamanAuthController < ApplicationController
  skip_before_action :authenticate_user!

  def request_signin
    xaman_client = Xaman::Client.new
    payload_data = xaman_client.create_signin_payload

    if payload_data && payload_data[:uuid]
      signin_token = SecureRandom.hex(16)

      Rails.cache.write("xaman_signin:#{signin_token}", payload_data[:uuid], expires_in: 5.minutes)

      response.headers["X-Signin-Token"] = signin_token

      render_success(
        data: payload_data,
        message: "SignIn payload created successfully. Token issued in X-Signin-Token header."
      )
    else
      render_error(message: "Failed to create Xaman payload", status: :unprocessable_entity)
    end
  end

  def verify_signin
    signin_token = request.headers["X-Signin-Token"]

    if signin_token.blank?
      return render_error(message: "Missing X-Signin-Token header", status: :bad_request)
    end

    payload_uuid = Rails.cache.read("xaman_signin:#{signin_token}")

    if payload_uuid.blank?
      return render_error(message: "Invalid or expired signin session", status: :unauthorized)
    end

    xaman_client = Xaman::Client.new
    xaman_data = xaman_client.verify_payload(payload_uuid)

    if xaman_data && xaman_data[:account].present?
      Rails.cache.delete("xaman_signin:#{signin_token}")

      user = User.find_or_create_by!(address: xaman_data[:account]) do |u|
        u.uid = xaman_data[:account]
        u.provider = "xaman"
        u.user_token = xaman_data[:user_token]
        u.name = xaman_data[:name]
        u.avatar_url = xaman_data[:avatar_url]
      end

      user.update(
        user_token: xaman_data[:user_token],
        name: xaman_data[:name] || user.name,
        avatar_url: xaman_data[:avatar_url] || user.avatar_url
      )

      auth_headers = user.create_new_auth_token
      response.headers.merge!(auth_headers)

      render_success(
        data: {
          id: user.id,
          address: user.address,
          user_token: user.user_token,
          name: user.name,
          avatar_url: user.avatar_url
        },
        message: "Signed in successfully"
      )
    else
      render_error(message: "Payload not signed yet or verification failed", status: :unauthorized)
    end
  end
end
