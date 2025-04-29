require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CREATED_PIPELINE_DEFINITION = :CIRCLECI_CREATED_PIPELINE_DEFINITION
    end

    class CircleciCreatePipelineDefinitionAction < Action
      def self.run(params)
        UI.message("Creating CircleCI pipeline definition via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        
        # Build the request body
        body = {
          "name" => params[:name],
          "config_source" => params[:config_source]
        }
        body["description"] = params[:description] if params[:description]
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("projects/#{project_id}/pipeline-definitions", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CREATED_PIPELINE_DEFINITION] = result
        
        UI.success("Successfully created pipeline definition '#{params[:name]}' for project #{project_id}")
        
        return result
      end

      def self.description
        "Creates a pipeline definition for a CircleCI project using API v2"
      end

      def self.details
        "This action creates a new pipeline definition for a specific CircleCI project using the CircleCI API v2. Pipeline definitions define how pipelines are configured for a project."
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
          FastlaneCore::ConfigItem.new(key: :name,
                                       description: "The name of the pipeline definition",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       description: "Optional description for the pipeline definition",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :config_source,
                                       description: "Configuration source for the pipeline definition",
                                       type: Hash,
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("config_source must contain 'provider'") unless value["provider"]
                                       end)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CREATED_PIPELINE_DEFINITION', 'A hash containing the created pipeline definition information']
        ]
      end

      def self.return_value
        "Returns a hash containing the created pipeline definition information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_pipeline_definition(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            name: "My Pipeline Definition",
            description: "A pipeline definition for my project",
            config_source: {
              "provider" => "github_app",
              "config_path" => ".circleci/config.yml"
            }
          )',
          'definition = circleci_create_pipeline_definition(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            name: "Bitbucket Pipeline Definition",
            config_source: {
              "provider" => "bitbucket_dc",
              "config_path" => ".circleci/config.yml",
              "branch" => "main"
            }
          )
          
          # Use the created pipeline definition
          UI.message("Created definition ID: #{definition["id"]}")'
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