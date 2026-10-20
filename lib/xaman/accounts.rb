# lib/xaman/accounts.rb

module Xaman
  class Accounts
    include Helpers::ApiRequest

    def initialize(connection:)
      @connection = connection
    end

    def find(account_address)
      api_request do
        @connection.get("account-meta/#{account_address}")
      end
    end
  end
end
