require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_CONFIG = :CIRCLECI_PIPELINE_CONFIG
    end

    class CircleciGetPipelineConfigAction < Action
      def self.run(params)
        UI.message("Getting CircleCI pipeline configuration via API v2...")
        
        api_token = params[:api_token]
        pipeline_id = params[:pipeline_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("pipeline/#{pipeline_id}/config", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_CONFIG] = result
        
        UI.success("Successfully retrieved configuration for pipeline #{pipeline_id}")
        
        return result
      end

      def self.description
        "Gets the configuration for a CircleCI pipeline using API v2"
      end

      def self.details
        "This action retrieves the configuration for a specific CircleCI pipeline using the CircleCI API v2. The configuration includes the source and compiled YAML configuration files."
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
                                       description: "The ID of the pipeline to retrieve configuration for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_CONFIG', 'A hash containing the pipeline configuration information']
        ]
      end

      def self.return_value
        "Returns a hash containing pipeline configuration information including source and compiled configurations."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_pipeline_config(
            pipeline_id: "01234567-89ab-cdef-0123-456789abcdef"
          )',
          'config = circleci_get_pipeline_config(
            pipeline_id: "01234567-89ab-cdef-0123-456789abcdef"
          )
          
          # Use the pipeline configuration information
          UI.message("Source config: #{config["source"]}")
          UI.message("Compiled config: #{config["compiled"]}")'
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