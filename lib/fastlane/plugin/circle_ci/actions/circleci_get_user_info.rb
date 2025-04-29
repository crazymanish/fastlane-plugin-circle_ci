require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_USER_INFO = :CIRCLECI_USER_INFO
    end

    class CircleciGetUserInfoAction < Action
      def self.run(params)
        UI.message("Getting CircleCI user information via API v2...")
        
        api_token = params[:api_token]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("me", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_USER_INFO] = result
        
        UI.success("Successfully retrieved user information for #{result["name"] || result["login"]}")
        
        return result
      end

      def self.description
        "Gets information about the authenticated CircleCI user using API v2"
      end

      def self.details
        "This action retrieves information about the currently authenticated CircleCI user using the CircleCI API v2. This includes details such as name, login, and ID."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CIRCLE_CI_API_TOKEN",
                                       description: "API Token for CircleCI API",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_USER_INFO', 'A hash containing the user information']
        ]
      end

      def self.return_value
        "Returns a hash containing user information including name, login, and ID."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_user_info',
          'user_info = circleci_get_user_info
          
          # Display user details
          puts "User: #{user_info["name"] || user_info["login"]}"
          puts "ID: #{user_info["id"]}"'
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :ci
      end
    end
  end
end