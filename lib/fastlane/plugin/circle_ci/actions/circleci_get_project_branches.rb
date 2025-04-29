require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PROJECT_BRANCHES = :CIRCLECI_PROJECT_BRANCHES
    end

    class CircleciGetProjectBranchesAction < Action
      def self.run(params)
        UI.message("Getting all branches for CircleCI project via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Build query parameters
        query_params = {}
        query_params["reporting-window"] = params[:reporting_window] if params[:reporting_window]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/branches", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PROJECT_BRANCHES] = result
        
        UI.success("Successfully retrieved all branches for project #{project_slug}")
        
        return result
      end

      def self.description
        "Gets all branches for a CircleCI project using Insights API v2"
      end

      def self.details
        "This action retrieves a list of all branches for a specified CircleCI project using the Insights API v2. The list will only contain branches currently available within Insights. The maximum number of branches returned is 5,000."
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
          FastlaneCore::ConfigItem.new(key: :reporting_window,
                                       description: "The time window used to calculate summary metrics (last-24-hours, last-7-days, last-90-days, etc.)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PROJECT_BRANCHES', 'A hash containing all branches information for the project']
        ]
      end

      def self.return_value
        "Returns a hash containing all branches information for the project."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_project_branches(
            project_slug: "gh/MyOrg/my-project"
          )',
          'branches = circleci_get_project_branches(
            project_slug: "gh/MyOrg/my-project",
            reporting_window: "last-90-days"
          )
          
          # Access the branch information
          branches["items"].each do |branch|
            UI.message("Branch: #{branch["name"]}")
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