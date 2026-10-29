module XamanService
  class VerifySignin
    attr_reader :payload_client, :uuid

    def self.call(uuid:)
      new(uuid).call
    end

    def initialize(uuid)
      @uuid = uuid
      @payload_client = Xaman.client.payloads
    end

    def call
      verify_signin(uuid)
    end

    def verify_signin(uuid)
      result = payload_client.find(uuid)
      return result unless result[:success]

      payload = result[:data]
      meta = payload["meta"] || {}

      unless meta["resolved"] == true && meta["signed"] == true
        return {
          success: false,
          data: nil,
          error: "Payload has not been successfully signed"
        }
      end

      {
        success: true,
        data: {
          account: payload.dig("response", "account"),
          name: payload.dig("response", "account_alias"),
          avatar_url: payload.dig("response", "account_avatar"),
          user_token: payload.dig("application", "issued_user_token") || payload.dig("response", "user_token")
        },
        error: nil
      }
    end
  end
end
