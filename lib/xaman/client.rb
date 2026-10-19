module Xaman
  class Client
    BASE_URL = "https://xumm.app/api/v1/platform".freeze

    def initialize(api_key = nil, api_secret = nil)
      @api_key = api_key || ENV.fetch("XAMAN_API_KEY", "")
      @api_secret = api_secret || ENV.fetch("XAMAN_API_SECRET", "")
    end

    # Create a SignIn Payload for user QR scanning
    def create_signin_payload
      response = connection.post("payload") do |req|
        req.body = { txjson: { TransactionType: "SignIn" } }.to_json
      end

      return nil unless response.success?

      data = parse_response(response)
      {
        uuid: data["uuid"],
        qr_code_url: data.dig("refs", "qr_png"),
        deep_link: data.dig("next", "always"),
        websocket_url: data.dig("refs", "websocket_status") # Thêm Websocket URL
      }
    end

    # Verify and fetch payload details using Payload UUID
    def verify_payload(payload_uuid)
      response = connection.get("payload/#{payload_uuid}")
      return nil unless response.success?

      data = parse_response(response)
      return nil unless data.dig("meta", "signed") == true

      {
        account: data.dig("response", "account"),
        user_token: data.dig("application", "issued_user_token"),
        name: data.dig("response", "account_alias"),
        avatar_url: data.dig("response", "account_avatar")
      }
    end

    def get_account_info(account_address)
      response = connection.get("account-info/#{account_address}")
      return nil unless response.success?

      parse_response(response)
    end

    private
    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |builder|
        builder.headers["Content-Type"] = "application/json"
        builder.headers["X-API-Key"] = @api_key
        builder.headers["X-API-Secret"] = @api_secret
        builder.adapter Faraday.default_adapter
      end
    end

    def parse_response(response)
      JSON.parse(response.body) if response.success?
    rescue JSON::ParserError
      nil
    end
  end
end
