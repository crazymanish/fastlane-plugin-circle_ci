require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_ORG_SUMMARY = :CIRCLECI_ORG_SUMMARY
    end

    class CircleciGetOrgSummaryAction < Action
      def self.run(params)
        UI.message("Getting organization summary metrics via Insights API v2...")
        
        api_token = params[:api_token]
        org_slug = params[:org_slug]
        
        # Build query parameters
        query_params = {}
        query_params["reporting-window"] = params[:reporting_window] if params[:reporting_window]
        query_params["project-names"] = params[:project_names].join(',') if params[:project_names]&.any?
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{org_slug}/summary", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_ORG_SUMMARY] = result
        
        UI.success("Successfully retrieved summary metrics for organization #{org_slug}")
        
        return result
      end

      def self.description
        "Gets summary metrics with trends for an entire organization using Insights API v2"
      end

      def self.details
        "This action retrieves aggregated summary metrics with trends for the entire organization and for each project belonging to the organization using the CircleCI Insights API v2."
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
          FastlaneCore::ConfigItem.new(key: :org_slug,
                                       env_name: "CIRCLE_CI_ORG_SLUG",
                                       description: "Organization slug (e.g., 'gh/MyOrg')",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :reporting_window,
                                       description: "The time window used to calculate summary metrics (last-24-hours, last-7-days, last-90-days, etc.)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_names,
                                       description: "List of project names to include in summary metrics",
                                       type: Array,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_ORG_SUMMARY', 'A hash containing organization summary metrics with trends']
        ]
      end

      def self.return_value
        "Returns a hash containing organization summary metrics with trends."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_org_summary(
            org_slug: "gh/MyOrg"
          )',
          'org_summary = circleci_get_org_summary(
            org_slug: "gh/MyOrg",
            reporting_window: "last-30-days",
            project_names: ["project-1", "project-2"]
          )
          
          # Access the organization summary metrics
          UI.message("Total Credits Used: #{org_summary["org_data"]["metrics"]["total_credits_used"]}")
          UI.message("Total Workflows: #{org_summary["org_data"]["metrics"]["total_runs"]}")
          
          # Access metrics for each project
          org_summary["org_projects"].each do |project|
            UI.message("Project: #{project["project_name"]}, Success Rate: #{project["metrics"]["success_rate"]}%")
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