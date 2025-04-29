require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_JOB_TIMESERIES = :CIRCLECI_JOB_TIMESERIES
    end

    class CircleciGetJobTimeseriesAction < Action
      def self.run(params)
        UI.message("Getting job timeseries data via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Build query parameters
        query_params = {}
        query_params["branch"] = params[:branch] if params[:branch]
        query_params["granularity"] = params[:granularity] if params[:granularity]
        query_params["start-date"] = params[:start_date] if params[:start_date]
        query_params["end-date"] = params[:end_date] if params[:end_date]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/time-series/#{project_slug}/workflows/#{workflow_name}/jobs", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_JOB_TIMESERIES] = result
        
        UI.success("Successfully retrieved job timeseries data for workflow #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets timeseries data for all jobs within a workflow using Insights API v2"
      end

      def self.details
        "This action retrieves timeseries data for all jobs within a workflow using the CircleCI Insights API v2. Hourly granularity data is only retained for 48 hours while daily granularity data is retained for 90 days."
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
                                       description: "Project slug in the form vcs-slug/org-name/repo-name",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :workflow_name,
                                       description: "The name of the workflow",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       description: "The name of a branch to filter for",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :granularity,
                                       description: "The granularity of timeseries data points (hourly, daily, etc.)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :start_date,
                                       description: "Include only executions that started at or after this date (format: YYYY-MM-DD)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :end_date,
                                       description: "Include only executions that started before this date (format: YYYY-MM-DD)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_JOB_TIMESERIES', 'An array of timeseries data, one entry per job']
        ]
      end

      def self.return_value
        "Returns an array of timeseries data, one entry per job."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_job_timeseries(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test"
          )',
          'timeseries_data = circleci_get_job_timeseries(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test",
            branch: "main",
            granularity: "daily",
            start_date: "2025-01-01",
            end_date: "2025-04-29"
          )
          
          # Process the timeseries data
          timeseries_data["items"].each do |job_data|
            UI.message("Job: #{job_data["name"]}")
            job_data["metrics"].each do |metric|
              UI.message("  #{metric["timestamp"]}: #{metric["total_runs"]} runs, #{metric["success_rate"]}% success rate")
            end
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