require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CONTINUED_PIPELINE = :CIRCLECI_CONTINUED_PIPELINE
    end

    class CircleciContinuePipelineAction < Action
      def self.run(params)
        UI.message("Continuing CircleCI pipeline via API v2...")
        
        api_token = params[:api_token]
        pipeline_id = params[:pipeline_id]
        parameters = params[:parameters]
        
        # Create the request body
        body = {}
        body["parameters"] = parameters if parameters
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("pipeline/continue", api_token, {
          "pipeline-id" => pipeline_id,
          "parameters" => parameters
        })
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CONTINUED_PIPELINE] = result
        
        UI.success("Successfully continued pipeline with ID #{pipeline_id}")
        
        return result
      end

      def self.description
        "Continues a pipeline from the setup phase using CircleCI API v2"
      end

      def self.details
        "This action continues a pipeline from the setup phase using the CircleCI API v2. This is useful for pipelines that require manual continuation or for dynamic configuration with parameters."
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
                                       description: "The ID of the pipeline to continue",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :parameters,
                                       description: "Parameters to pass to the pipeline continuation (for dynamic config)",
                                       type: Hash,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CONTINUED_PIPELINE', 'A hash containing the continued pipeline information']
        ]
      end

      def self.return_value
        "Returns a hash containing information about the continued pipeline."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_continue_pipeline(
            pipeline_id: "01234567-89ab-cdef-0123-456789abcdef"
          )',
          'continued_pipeline = circleci_continue_pipeline(
            pipeline_id: "01234567-89ab-cdef-0123-456789abcdef",
            parameters: {
              "deploy_env" => "staging",
              "version" => "1.2.3"
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