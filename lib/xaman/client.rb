# lib/xaman/client.rb

module Xaman
  class Client
    include Helpers::ApiRequest

    def initialize
      @connection = Connection.new.connection
    end

    def payloads
      @payloads ||= Payloads.new(connection: @connection)
    end

    def accounts
      @accounts ||= Accounts.new(connection: @connection)
    end

    def user_tokens
      @user_tokens ||= UserTokens.new(connection: @connection)
    end

    def networks
      @networks ||= Networks.new(connection: @connection)
    end

    def ping
      api_request do
        @connection.get("ping")
      end
    end
  end
end
