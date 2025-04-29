require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_BY_NUMBER = :CIRCLECI_PIPELINE_BY_NUMBER
    end

    class CircleciGetPipelineByNumberAction < Action
      def self.run(params)
        UI.message("Getting CircleCI pipeline by number via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        pipeline_number = params[:pipeline_number]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/pipeline/#{pipeline_number}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_BY_NUMBER] = result
        
        UI.success("Successfully retrieved pipeline number #{pipeline_number} for project #{project_slug}")
        
        return result
      end

      def self.description
        "Gets a specific pipeline by number from CircleCI using API v2"
      end

      def self.details
        "This action retrieves details about a specific pipeline by its number from CircleCI using the CircleCI API v2."
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
          FastlaneCore::ConfigItem.new(key: :project_slug,
                                       env_name: "CIRCLE_CI_PROJECT_SLUG",
                                       description: "Project slug in the form of :vcs-type/:org-name/:project-name (e.g. github/myorg/myrepo)",
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_PROJECT_SLUG"],
                                       default_value_dynamic: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :pipeline_number,
                                       env_name: "CIRCLE_CI_PIPELINE_NUMBER",
                                       description: "The number of the pipeline to retrieve",
                                       is_string: false,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_BY_NUMBER', 'A hash containing the pipeline details']
        ]
      end

      def self.return_value
        "Returns a hash containing pipeline details including state, created timestamp, and trigger information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_pipeline_by_number(
            project_slug: "github/myorg/myrepo",
            pipeline_number: 123
          )',
          'pipeline = circleci_get_pipeline_by_number(
            project_slug: "github/myorg/myrepo",
            pipeline_number: 123
          )
          
          if pipeline["state"] == "success"
            puts "Pipeline #{pipeline["number"]} completed successfully at #{pipeline["created_at"]}"
          else
            puts "Pipeline #{pipeline["number"]} is in state: #{pipeline["state"]}"
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