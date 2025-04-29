require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeletePipelineDefinitionAction < Action
      def self.run(params)
        UI.message("Deleting CircleCI pipeline definition via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        pipeline_definition_id = params[:pipeline_definition_id]
        
        # Make API request
        result = Helper::CircleCiHelper.delete_v2("projects/#{project_id}/pipeline-definitions/#{pipeline_definition_id}", api_token)
        
        UI.success("Successfully deleted pipeline definition with ID #{pipeline_definition_id}")
        
        return result
      end

      def self.description
        "Deletes a pipeline definition from CircleCI using API v2"
      end

      def self.details
        "This action deletes a specific pipeline definition from CircleCI using the CircleCI API v2."
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
                                       description: "The ID of the pipeline definition to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with a 'message' key indicating success or failure."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_pipeline_definition(
            project_id: "01234567-89ab-cdef-0123-456789abcdef",
            pipeline_definition_id: "fedcba98-7654-3210-fedc-ba9876543210"
          )',
          '# Get definitions first, then delete one
          definitions = circleci_get_pipeline_definitions(
            project_id: "01234567-89ab-cdef-0123-456789abcdef"
          )
          
          # Delete the first definition
          if definitions["items"].any?
            circleci_delete_pipeline_definition(
              project_id: "01234567-89ab-cdef-0123-456789abcdef",
              pipeline_definition_id: definitions["items"].first["id"]
            )
          end'
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