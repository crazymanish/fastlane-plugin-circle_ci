require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_JOB_METRICS = :CIRCLECI_WORKFLOW_JOB_METRICS
    end

    class CircleciGetWorkflowJobMetricsAction < Action
      def self.run(params)
        UI.message("Getting job metrics for CircleCI workflow via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Build query parameters
        query_params = {}
        query_params["branch"] = params[:branch] if params[:branch]
        query_params["reporting-window"] = params[:reporting_window] if params[:reporting_window]
        query_params["page-token"] = params[:page_token] if params[:page_token]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/workflows/#{workflow_name}/jobs", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_JOB_METRICS] = result
        
        UI.success("Successfully retrieved job metrics for workflow #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets summary metrics for a project workflow's jobs using Insights API v2"
      end

      def self.details
        "This action retrieves summary metrics for a project workflow's jobs using the CircleCI Insights API v2. Job runs going back at most 90 days are included in the aggregation window. Metrics are refreshed daily, and thus may not include executions from the last 24 hours."
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
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :page_token,
                                       description: "A token to retrieve the next page of results",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_JOB_METRICS', 'A hash containing job metrics for the workflow']
        ]
      end

      def self.return_value
        "Returns a hash containing job metrics for the workflow."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_job_metrics(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test"
          )',
          'job_metrics = circleci_get_workflow_job_metrics(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test",
            branch: "main",
            reporting_window: "last-30-days"
          )
          
          # Access the job metrics
          job_metrics["items"].each do |job|
            UI.message("Job: #{job["name"]}, Success Rate: #{job["success_rate"]}, Duration: #{job["duration_metrics"]["median"]}ms")
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