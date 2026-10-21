# lib/xaman/payloads.rb

module Xaman
  class Payloads
    include Helpers::ApiRequest

    def initialize(connection:)
      @connection = connection
    end

    def create(txjson:, options: nil, custom_meta: nil, user_token: nil)
      body = { txjson: txjson }
      body[:options] = options if options
      body[:custom_meta] = custom_meta if custom_meta
      body[:user_token] = user_token if user_token

      result = api_request do
        @connection.post("payload") do |request|
          request.body = body.to_json
        end
      end

      return result unless result[:success]

      payload = result[:data]

      {
        success: true,
        data: {
          uuid: payload["uuid"],
          qr_code_url: payload.dig("refs", "qr_png"),
          deep_link: payload.dig("next", "always"),
          websocket_url: payload.dig("refs", "websocket_status")
        },
        error: nil
      }
    end

    def find(uuid)
      api_request do
        @connection.get("payload/#{uuid}")
      end
    end
  end
end
