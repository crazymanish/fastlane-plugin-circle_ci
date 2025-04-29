require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_MY_PIPELINES = :CIRCLECI_MY_PIPELINES
    end

    class CircleciGetMyPipelinesAction < Action
      def self.run(params)
        UI.message("Getting recent CircleCI pipelines for current user via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/pipeline/mine", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_MY_PIPELINES] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} recent pipelines for current user")
        
        return result["items"]
      end

      def self.description
        "Gets recent pipelines for the current user from CircleCI using API v2"
      end

      def self.details
        "This action retrieves recent pipelines triggered by or associated with the current user from CircleCI using the CircleCI API v2."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_MY_PIPELINES', 'An array of pipeline data for the current user']
        ]
      end

      def self.return_value
        "Returns an array of pipeline data including IDs, numbers, states, and created timestamps."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_my_pipelines(
            project_slug: "github/myorg/myrepo"
          )',
          'my_pipelines = circleci_get_my_pipelines(
            project_slug: "github/myorg/myrepo"
          )
          
          # Print details of recent pipelines
          my_pipelines.each do |pipeline|
            puts "Pipeline ##{pipeline["number"]}: #{pipeline["state"]} (#{pipeline["created_at"]})"
          end
          
          # Find a successful pipeline
          success_pipeline = my_pipelines.find { |p| p["state"] == "success" }
          if success_pipeline
            puts "Latest successful pipeline: ##{success_pipeline["number"]}"
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