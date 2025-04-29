require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_SUMMARY = :CIRCLECI_WORKFLOW_SUMMARY
    end

    class CircleciGetWorkflowSummaryAction < Action
      def self.run(params)
        UI.message("Getting workflow summary metrics via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Build query parameters
        query_params = {}
        query_params["branch"] = params[:branch] if params[:branch]
        query_params["reporting-window"] = params[:reporting_window] if params[:reporting_window]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/workflows/#{workflow_name}/summary", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_SUMMARY] = result
        
        UI.success("Successfully retrieved summary metrics for workflow #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets metrics and trends for a workflow using Insights API v2"
      end

      def self.details
        "This action retrieves metrics and trends for a particular workflow on a single branch or all branches using the CircleCI Insights API v2."
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
          FastlaneCore::ConfigItem.new(key: :reporting_window,
                                       description: "The time window used to calculate summary metrics (last-24-hours, last-7-days, last-90-days, etc.)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_SUMMARY', 'A hash containing workflow summary metrics and trends']
        ]
      end

      def self.return_value
        "Returns a hash containing workflow summary metrics and trends."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_summary(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test"
          )',
          'summary = circleci_get_workflow_summary(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test",
            branch: "main",
            reporting_window: "last-30-days"
          )
          
          # Access the workflow summary metrics
          UI.message("Total Runs: #{summary["total_runs"]}")
          UI.message("Success Rate: #{summary["success_rate"]}%")
          UI.message("Median Duration: #{summary["duration_metrics"]["median"]} ms")'
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