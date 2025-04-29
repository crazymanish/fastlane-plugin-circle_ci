require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_UPDATED_TRIGGER = :CIRCLECI_UPDATED_TRIGGER
    end

    class CircleciUpdateTriggerAction < Action
      def self.run(params)
        UI.message("Updating CircleCI trigger via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        trigger_id = params[:trigger_id]
        
        # Build the request body with only provided parameters
        body = {}
        body["description"] = params[:description] if params[:description]
        body["config"] = params[:config] if params[:config]
        
        # Make API request
        result = Helper::CircleCiHelper.patch_v2("projects/#{project_id}/triggers/#{trigger_id}", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_UPDATED_TRIGGER] = result
        
        UI.success("Successfully updated trigger with ID #{trigger_id}")
        
        return result
      end

      def self.description
        "Updates a trigger in CircleCI using API v2"
      end

      def self.details
        "This action updates an existing trigger in CircleCI using the CircleCI API v2. You can update the description and configuration of the trigger."
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
                                       description: "The ID of the trigger to update",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       description: "Updated description for the trigger",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :config,
                                       description: "Updated configuration for the trigger (varies by trigger type)",
                                       type: Hash,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_UPDATED_TRIGGER', 'A hash containing the updated trigger information']
        ]
      end

      def self.return_value
        "Returns a hash containing the updated trigger information."
      end

      def self.authors
        ["crazymanish, "copilot""]
      end

      def self.example_code
        [
          'circleci_update_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            trigger_id: "fedcba98-7654-3210-fedc-ba9876543210",
            description: "Updated webhook trigger description"
          )',
          'updated_trigger = circleci_update_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            trigger_id: "fedcba98-7654-3210-fedc-ba9876543210",
            description: "Updated GitHub PR Trigger",
            config: {
              "targetBranchMatchers" => ["main", "develop/*", "feature/*"]
            }
          )'
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