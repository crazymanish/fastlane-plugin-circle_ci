require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE = :CIRCLECI_PIPELINE
    end

    class CircleciGetPipelineAction < Action
      def self.run(params)
        UI.message("Getting CircleCI pipeline via API v2...")
        
        api_token = params[:api_token]
        pipeline_id = params[:pipeline_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("pipeline/#{pipeline_id}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE] = result
        
        UI.success("Successfully retrieved pipeline #{pipeline_id}")
        
        return result
      end

      def self.description
        "Gets information about a CircleCI pipeline using API v2"
      end

      def self.details
        "This action retrieves detailed information about a specific CircleCI pipeline using the CircleCI API v2, including state, created timestamp, trigger information, and VCS data."
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
          FastlaneCore::ConfigItem.new(key: :pipeline_id,
                                       env_name: "CIRCLE_CI_PIPELINE_ID",
                                       description: "The ID of the pipeline to get information for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE', 'A hash containing the pipeline details']
        ]
      end

      def self.return_value
        "Returns a hash containing detailed pipeline information including state, created timestamp, trigger information, and VCS data."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_pipeline(
            pipeline_id: "pipeline-uuid"
          )',
          'pipeline = circleci_get_pipeline(
            pipeline_id: "pipeline-uuid"
          )
          
          # Print pipeline details
          puts "Pipeline state: #{pipeline["state"]}"
          puts "Created at: #{pipeline["created_at"]}"
          puts "Trigger: #{pipeline["trigger"]["type"]}"
          
          # Check if pipeline is for a specific branch
          if pipeline["vcs"] && pipeline["vcs"]["branch"] == "main"
            UI.important("This is a main branch pipeline!")
          end
          
          # Get workflows for this pipeline
          workflows = circleci_get_pipeline_workflows(
            pipeline_id: pipeline["id"]
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