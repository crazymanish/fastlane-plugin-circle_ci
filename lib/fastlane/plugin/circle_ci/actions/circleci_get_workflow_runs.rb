require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_RUNS = :CIRCLECI_WORKFLOW_RUNS
    end

    class CircleciGetWorkflowRunsAction < Action
      def self.run(params)
        UI.message("Getting recent workflow runs via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Build query parameters
        query_params = {}
        query_params["branch"] = params[:branch] if params[:branch]
        query_params["start-date"] = params[:start_date] if params[:start_date]
        query_params["end-date"] = params[:end_date] if params[:end_date]
        query_params["page-token"] = params[:page_token] if params[:page_token]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/workflows/#{workflow_name}", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_RUNS] = result
        
        UI.success("Successfully retrieved recent runs for workflow #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets recent runs of a workflow using Insights API v2"
      end

      def self.details
        "This action retrieves recent runs of a workflow using the CircleCI Insights API v2. Runs going back at most 90 days are returned."
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
          FastlaneCore::ConfigItem.new(key: :workflow_name,
                                       description: "The name of the workflow",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       description: "The name of a branch to filter for",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :start_date,
                                       description: "Include only executions that started at or after this date (format: YYYY-MM-DD)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :end_date,
                                       description: "Include only executions that started before this date (format: YYYY-MM-DD)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :page_token,
                                       description: "A token to retrieve the next page of results",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_RUNS', 'A hash containing recent workflow runs']
        ]
      end

      def self.return_value
        "Returns a hash containing recent workflow runs."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_runs(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test"
          )',
          'runs = circleci_get_workflow_runs(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test",
            branch: "main",
            start_date: "2025-01-01",
            end_date: "2025-04-29"
          )
          
          # Access the workflow runs
          runs["items"].each do |run|
            UI.message("Run ID: #{run["id"]}, Status: #{run["status"]}, Started: #{run["created_at"]}")
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