# lib/xaman/helpers/api_request.rb

module Xaman
  module Helpers
    module ApiRequest
      private
      def api_request
        response = yield
        Response.new(response).to_h
      rescue Faraday::Error => e
        failure_response(e.message)
      end

      def failure_response(message)
        {
          success: false,
          data: nil,
          error: message
        }
      end
    end
  end
end
