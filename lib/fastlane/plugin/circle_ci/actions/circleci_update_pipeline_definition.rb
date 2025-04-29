require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_UPDATED_PIPELINE_DEFINITION = :CIRCLECI_UPDATED_PIPELINE_DEFINITION
    end

    class CircleciUpdatePipelineDefinitionAction < Action
      def self.run(params)
        UI.message("Updating CircleCI pipeline definition via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        pipeline_definition_id = params[:pipeline_definition_id]
        
        # Build the request body with only provided parameters
        body = {}
        body["name"] = params[:name] if params[:name]
        body["description"] = params[:description] if params[:description]
        body["config_source"] = params[:config_source] if params[:config_source]
        
        # Make API request
        result = Helper::CircleCiHelper.patch_v2("projects/#{project_id}/pipeline-definitions/#{pipeline_definition_id}", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_UPDATED_PIPELINE_DEFINITION] = result
        
        UI.success("Successfully updated pipeline definition with ID #{pipeline_definition_id}")
        
        return result
      end

      def self.description
        "Updates a pipeline definition in CircleCI using API v2"
      end

      def self.details
        "This action updates an existing pipeline definition in CircleCI using the CircleCI API v2. Currently only supported for pipeline definitions where config_source.provider is github_app or bitbucket_dc."
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
                                       description: "The ID of the pipeline definition to update",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :name,
                                       description: "New name for the pipeline definition",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :description,
                                       description: "New description for the pipeline definition",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :config_source,
                                       description: "New configuration source for the pipeline definition",
                                       type: Hash,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("config_source must contain 'provider'") unless value["provider"]
                                       end)
        ]
      end

      def self.output
        [
          ['CIRCLECI_UPDATED_PIPELINE_DEFINITION', 'A hash containing the updated pipeline definition information']
        ]
      end

      def self.return_value
        "Returns a hash containing the updated pipeline definition information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_update_pipeline_definition(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            pipeline_definition_id: "fedcba98-7654-3210-fedc-ba9876543210",
            name: "Updated Pipeline Definition Name"
          )',
          'updated_definition = circleci_update_pipeline_definition(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            pipeline_definition_id: "fedcba98-7654-3210-fedc-ba9876543210",
            description: "Updated pipeline definition description",
            config_source: {
              "provider" => "github_app",
              "config_path" => ".circleci/updated-config.yml",
              "branch" => "feature/new-branch"
            }
          )
          
          # Use the updated pipeline definition
          UI.message("Updated definition name: #{updated_definition["name"]}")'
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