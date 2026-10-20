# lib/xaman.rb

require "singleton"
require "json"
require "faraday"

module Xaman
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.instance
    end

    def configure
      yield(configuration)
      reset_client!
    end

    def client
      @client ||= Client.new
    end

    def reset_client!
      @client = nil
    end
  end

  class Configuration
    include Singleton

    attr_accessor :api_key, :api_secret, :base_url
  end
end

require_relative "xaman/connection"
require_relative "xaman/response"
require_relative "xaman/helpers/api_request"
require_relative "xaman/payloads"
require_relative "xaman/accounts"
require_relative "xaman/user_tokens"
require_relative "xaman/networks"
require_relative "xaman/client"
