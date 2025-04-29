require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_TRIGGER_INFO = :CIRCLECI_TRIGGER_INFO
    end

    class CircleciGetTriggerAction < Action
      def self.run(params)
        UI.message("Getting CircleCI trigger information via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        trigger_id = params[:trigger_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("projects/#{project_id}/triggers/#{trigger_id}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_TRIGGER_INFO] = result
        
        UI.success("Successfully retrieved trigger information")
        
        return result
      end

      def self.description
        "Gets information about a specific trigger using CircleCI API v2"
      end

      def self.details
        "This action retrieves detailed information about a specific trigger using the CircleCI API v2."
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
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: "CIRCLE_CI_PROJECT_ID",
                                       description: "The ID of the CircleCI project",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :trigger_id,
                                       description: "The ID of the trigger to retrieve",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_TRIGGER_INFO', 'A hash containing the trigger information']
        ]
      end

      def self.return_value
        "Returns a hash containing detailed information about the trigger."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            trigger_id: "fedcba98-7654-3210-fedc-ba9876543210"
          )',
          'trigger_info = circleci_get_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            trigger_id: "fedcba98-7654-3210-fedc-ba9876543210"
          )
          
          # Use the trigger information
          UI.message("Trigger type: #{trigger_info["type"]}, Description: #{trigger_info["description"]}")'
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