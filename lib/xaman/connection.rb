# lib/xaman/connection.rb

module Xaman
  class Connection
    def initialize
      @config = Xaman.configuration
    end

    def connection
      @connection ||= Faraday.new(url: @config.base_url) do |builder|
        builder.headers["Content-Type"] = "application/json"
        builder.headers["Accept"] = "application/json"
        builder.headers["X-API-Key"] = @config.api_key
        builder.headers["X-API-Secret"] = @config.api_secret

        builder.adapter Faraday.default_adapter
      end
    end
  end
end
