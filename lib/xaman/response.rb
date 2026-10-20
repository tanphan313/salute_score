# lib/xaman/response.rb

module Xaman
  class Response
    attr_reader :status, :data, :error

    def initialize(response)
      @status = response.status
      @data = parse_body(response.body)
      @error = extract_error(response)
    end

    def success?
      (200..299).cover?(status) && error.nil?
    end

    def to_h
      {
        success: success?,
        data: success? ? data : nil,
        error: error
      }
    end

    private
    def parse_body(body)
      JSON.parse(body)
    rescue JSON::ParserError, TypeError
      nil
    end

    def extract_error(response)
      unless response.success?
        return data["message"] || data["error"] ||
               "Xaman API request failed with status #{status}" if data.is_a?(Hash)

        return "Xaman API request failed with status #{status}"
      end

      return nil unless data.nil?

      "Invalid JSON response from Xaman API"
    end
  end
end
