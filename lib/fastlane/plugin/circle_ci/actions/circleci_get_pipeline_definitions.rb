require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_DEFINITIONS = :CIRCLECI_PIPELINE_DEFINITIONS
    end

    class CircleciGetPipelineDefinitionsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI pipeline definitions via API v2...")
        
        api_token = params[:api_token]
        project_id = params[:project_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("projects/#{project_id}/pipeline-definitions", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_DEFINITIONS] = result
        
        UI.success("Successfully retrieved pipeline definitions for project #{project_id}")
        
        return result
      end

      def self.description
        "Gets pipeline definitions for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves all pipeline definitions for a specific CircleCI project using the CircleCI API v2. Pipeline definitions describe how pipelines are configured for a project."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_DEFINITIONS', 'A hash containing pipeline definitions information']
        ]
      end

      def self.return_value
        "Returns a hash containing pipeline definitions information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_pipeline_definitions(
            project_id: "01234567-89ab-cdef-0123-456789abcdef"
          )',
          'definitions = circleci_get_pipeline_definitions(
            project_id: "01234567-89ab-cdef-0123-456789abcdef"
          )
          
          # Use the pipeline definitions information
          definitions["items"].each do |definition|
            UI.message("Definition ID: #{definition["id"]}, Name: #{definition["name"]}")
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