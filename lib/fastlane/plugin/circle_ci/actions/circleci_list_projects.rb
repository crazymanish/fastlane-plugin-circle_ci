require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PROJECTS = :CIRCLECI_PROJECTS
    end

    class CircleciListProjectsAction < Action
      def self.run(params)
        UI.message("Listing CircleCI projects via API v2...")
        
        api_token = params[:api_token]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("projects", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PROJECTS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} projects")
        
        return result["items"]
      end

      def self.description
        "Lists all CircleCI projects for the current user or organization using API v2"
      end

      def self.details
        "This action retrieves all CircleCI projects that the current API token has access to using the CircleCI API v2."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PROJECTS', 'An array of project data']
        ]
      end

      def self.return_value
        "Returns an array of project data including names, slugs, and VCS information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_list_projects',
          'projects = circleci_list_projects
          # Find a specific project by name
          my_project = projects.find { |project| project["name"] == "my-repo-name" }
          
          # Use the project slug for other actions
          if my_project
            circleci_trigger_pipeline(
              project_slug: my_project["slug"],
              branch: "main"
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