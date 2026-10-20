# lib/xaman/user_tokens.rb

module Xaman
  class UserTokens
    include Helpers::ApiRequest

    def initialize(connection:)
      @connection = connection
    end

    def find(token)
      api_request do
        @connection.get("user-token/#{token}")
      end
    end

    def check(tokens)
      api_request do
        @connection.post("user-tokens") do |request|
          request.body = { tokens: tokens }.to_json
        end
      end
    end
  end
end
