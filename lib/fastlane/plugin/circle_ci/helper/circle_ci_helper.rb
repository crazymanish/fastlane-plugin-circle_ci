require 'fastlane_core/ui/ui'
require 'faraday'
require 'json'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CircleCiHelper
      # Legacy v1.1 API support
      def self.execute(curl_command)
        response = Fastlane::Actions::sh("#{curl_command}", log: false)

        JSON.parse(response) || {}
      end

      # CircleCI API v2 base URL
      API_V2_BASE_URL = "https://circleci.com/api/v2".freeze

      # Makes a GET request to CircleCI API v2
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @param params [Hash] Optional query parameters
      # @return [Hash] The parsed JSON response
      def self.get_v2(path, token, params = {})
        make_request(:get, path, token, nil, params)
      end

      # Makes a POST request to CircleCI API v2
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @param body [Hash] The request body
      # @return [Hash] The parsed JSON response
      def self.post_v2(path, token, body = {})
        make_request(:post, path, token, body)
      end

      # Makes a PUT request to CircleCI API v2
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @param body [Hash] The request body
      # @return [Hash] The parsed JSON response
      def self.put_v2(path, token, body = {})
        make_request(:put, path, token, body)
      end

      # Makes a DELETE request to CircleCI API v2
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @return [Hash] The parsed JSON response
      def self.delete_v2(path, token)
        make_request(:delete, path, token)
      end

      # Makes a PATCH request to CircleCI API v2
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @param body [Hash] The request body
      # @return [Hash] The parsed JSON response
      def self.patch_v2(path, token, body = {})
        make_request(:patch, path, token, body)
      end

      # Makes an HTTP request to the CircleCI API v2
      # @param method [Symbol] The HTTP method (:get, :post, :put, :delete, :patch)
      # @param path [String] The API endpoint path
      # @param token [String] The CircleCI API token
      # @param body [Hash] The request body for POST, PUT, or PATCH requests
      # @param params [Hash] Query parameters for GET requests
      # @return [Hash] The parsed JSON response
      def self.make_request(method, path, token, body = nil, params = {})
        conn = Faraday.new(url: API_V2_BASE_URL) do |faraday|
          faraday.headers['Circle-Token'] = token
          faraday.headers['Content-Type'] = 'application/json'
          faraday.headers['Accept'] = 'application/json'
          faraday.adapter Faraday.default_adapter
        end

        begin
          response = case method
                     when :get
                       conn.get(path, params)
                     when :post
                       conn.post(path) do |req|
                         req.body = body.to_json if body
                       end
                     when :put
                       conn.put(path) do |req|
                         req.body = body.to_json if body
                       end
                     when :patch
                       conn.patch(path) do |req|
                         req.body = body.to_json if body
                       end
                     when :delete
                       conn.delete(path)
                     end

          if response.status >= 200 && response.status < 300
            response_body = response.body.empty? ? "{}" : response.body
            JSON.parse(response_body)
          else
            error_msg = "CircleCI API error (#{response.status}): #{response.body}"
            UI.error(error_msg)
            raise error_msg
          end
        rescue Faraday::Error => e
          UI.error("Network error: #{e.message}")
          raise e
        rescue JSON::ParserError => e
          UI.error("JSON parsing error: #{e.message}")
          raise e
        end
      end
    end
  end
end
