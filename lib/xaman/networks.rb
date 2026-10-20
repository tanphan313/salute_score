# lib/xaman/networks.rb

module Xaman
  class Networks
    include Helpers::ApiRequest

    def initialize(connection:)
      @connection = connection
    end

    def all
      api_request do
        @connection.get("rails")
      end
    end
  end
end
