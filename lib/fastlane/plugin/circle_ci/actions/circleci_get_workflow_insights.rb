require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_INSIGHTS = :CIRCLECI_WORKFLOW_INSIGHTS
    end

    class CircleciGetWorkflowInsightsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI workflow insights via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Construct query parameters
        query_params = []
        
        # Add optional parameters if provided
        query_params << "branches=#{params[:branches].join(',')}" if params[:branches]
        query_params << "branch=#{params[:branch]}" if params[:branch]
        query_params << "start-date=#{params[:start_date]}" if params[:start_date]
        query_params << "end-date=#{params[:end_date]}" if params[:end_date]
        
        # Construct the query string
        query_string = query_params.empty? ? "" : "?#{query_params.join('&')}"
        
        # Make API request
        endpoint = "insights/#{project_slug}/workflows/#{workflow_name}#{query_string}"
        result = Helper::CircleCiHelper.get_v2(endpoint, api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_INSIGHTS] = result
        
        UI.success("Successfully retrieved workflow insights for #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets workflow insights data from CircleCI using API v2"
      end

      def self.details
        "This action retrieves detailed insights and metrics for a specific workflow in a project using the CircleCI API v2. " +
        "The data includes success rates, duration metrics, and historical trends for the specified workflow."
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
                                       env_name: "CIRCLE_CI_WORKFLOW_NAME",
                                       description: "The name of the workflow to get insights for",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :branches,
                                       env_name: "CIRCLE_CI_BRANCHES",
                                       description: "The names of branches to include in the results (array)",
                                       is_string: false,
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "CIRCLE_CI_BRANCH",
                                       description: "The name of a specific branch to filter results",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :start_date,
                                       env_name: "CIRCLE_CI_START_DATE",
                                       description: "The start date for the report in YYYY-MM-DD format",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :end_date,
                                       env_name: "CIRCLE_CI_END_DATE",
                                       description: "The end date for the report in YYYY-MM-DD format",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_INSIGHTS', 'A hash containing the workflow insights data']
        ]
      end

      def self.return_value
        "Returns a hash containing workflow insights data including metrics, durations, and trends."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_insights(
            project_slug: "github/myorg/myrepo",
            workflow_name: "build-test-deploy"
          )',
          '# Get workflow insights for a specific date range and branch
          insights = circleci_get_workflow_insights(
            project_slug: "github/myorg/myrepo",
            workflow_name: "build-test-deploy",
            branch: "main",
            start_date: "2023-01-01",
            end_date: "2023-01-31"
          )
          
          # Analyze insights data
          success_rate = insights["success_rate"]
          median_duration_secs = insights["metrics"]["duration_metrics"]["median"]
          total_runs = insights["metrics"]["total_runs"]
          
          # Report findings
          UI.message("Workflow success rate: #{success_rate}%")
          UI.message("Median duration: #{median_duration_secs / 60.0} minutes")
          UI.message("Total runs: #{total_runs}")
          
          # Look for duration trends
          if insights["trends"] && insights["trends"]["duration_trend"] > 0
            UI.important("⚠️ Build times are trending upward!")
          elsif insights["trends"] && insights["trends"]["duration_trend"] < 0
            UI.success("✅ Build times are trending downward!")
          else
            UI.message("Build times are stable")
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