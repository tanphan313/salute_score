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

    def create_signin
      create(
        txjson: {
          TransactionType: "SignIn"
        }
      )
    end

    def find(uuid)
      api_request do
        @connection.get("payload/#{uuid}")
      end
    end

    def status(uuid)
      result = find(uuid)
      return result unless result[:success]

      payload = result[:data]
      meta = payload["meta"] || {}
      response = payload["response"] || {}

      {
        success: true,
        data: {
          uuid: payload["uuid"] || uuid,
          resolved: meta["resolved"],
          signed: meta["signed"],
          cancelled: meta["cancelled"],
          expired: meta["expired"],
          account: response["account"],
          transaction_id: response["txid"],
          user_token: payload.dig("application", "issued_user_token")
        },
        error: nil
      }
    end

    def verify_signin(uuid)
      result = find(uuid)
      return result unless result[:success]

      payload = result[:data]
      meta = payload["meta"] || {}

      unless meta["resolved"] == true && meta["signed"] == true
        return failure_response("Payload has not been successfully signed")
      end

      {
        success: true,
        data: {
          account: payload.dig("response", "account"),
          name: payload.dig("response", "account_alias"),
          avatar_url: payload.dig("response", "account_avatar")
        },
        error: nil
      }
    end
  end
end
