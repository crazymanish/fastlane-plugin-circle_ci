require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_DEFINITION_TRIGGER = :CIRCLECI_PIPELINE_DEFINITION_TRIGGER
    end

    class CircleciCreatePipelineDefinitionTriggerAction < Action
      def self.run(params)
        UI.message("Creating CircleCI pipeline definition trigger via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        pipeline_definition_id = params[:pipeline_definition_id]
        trigger_type = params[:trigger_type]
        description = params[:description]
        config = params[:config]
        
        # Create the request body
        body = {
          "type" => trigger_type,
          "description" => description,
          "config" => config
        }
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("projects/#{project_id}/pipeline-definitions/#{pipeline_definition_id}/triggers", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_DEFINITION_TRIGGER] = result
        
        UI.success("Successfully created pipeline definition trigger")
        
        return result
      end

      def self.description
        "Creates a trigger for a pipeline definition using CircleCI API v2"
      end

      def self.details
        "This action creates a new trigger for a specific pipeline definition using the CircleCI API v2. Triggers allow you to automatically start pipelines based on events."
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
          FastlaneCore::ConfigItem.new(key: :pipeline_definition_id,
                                       description: "The ID of the pipeline definition",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :trigger_type,
                                       description: "The type of trigger to create (e.g., 'webhook', 'github', etc.)",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       description: "A description for the trigger",
                                       is_string: true,
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :config,
                                       description: "Configuration for the trigger (varies by trigger type)",
                                       type: Hash,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_DEFINITION_TRIGGER', 'A hash containing the created trigger information']
        ]
      end

      def self.return_value
        "Returns a hash containing the created trigger information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_pipeline_definition_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            pipeline_definition_id: "fedcba98-7654-3210-fedc-ba9876543210",
            trigger_type: "webhook",
            description: "My webhook trigger",
            config: {
              "authType" => "NONE"
            }
          )',
          'trigger = circleci_create_pipeline_definition_trigger(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            pipeline_definition_id: "fedcba98-7654-3210-fedc-ba9876543210",
            trigger_type: "github",
            description: "GitHub Push Trigger",
            config: {
              "pushEventType" => "BRANCHES",
              "targetBranchMatchers" => ["main", "develop/*"]
            }
          )
          
          # Use the created trigger information
          UI.message("Created trigger ID: #{trigger["id"]}")'
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