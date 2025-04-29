require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_TEST_METRICS = :CIRCLECI_WORKFLOW_TEST_METRICS
    end

    class CircleciGetWorkflowTestMetricsAction < Action
      def self.run(params)
        UI.message("Getting test metrics for CircleCI workflow via Insights API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        workflow_name = params[:workflow_name]
        
        # Build query parameters
        query_params = {}
        query_params["branch"] = params[:branch] if params[:branch]
        query_params["page-token"] = params[:page_token] if params[:page_token]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/workflows/#{workflow_name}/test-metrics", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_TEST_METRICS] = result
        
        UI.success("Successfully retrieved test metrics for workflow #{workflow_name}")
        
        return result
      end

      def self.description
        "Gets test metrics for a project workflow using Insights API v2"
      end

      def self.details
        "This action retrieves test metrics for a project workflow using the CircleCI Insights API v2. Currently test metrics are calculated based on the 10 most recent workflow runs."
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
          FastlaneCore::ConfigItem.new(key: :page_token,
                                       description: "A token to retrieve the next page of results",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_TEST_METRICS', 'A hash containing test metrics for the workflow']
        ]
      end

      def self.return_value
        "Returns a hash containing test metrics for the workflow."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_test_metrics(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test"
          )',
          'test_metrics = circleci_get_workflow_test_metrics(
            project_slug: "gh/MyOrg/my-project",
            workflow_name: "build-and-test",
            branch: "main"
          )
          
          # Access the test metrics
          test_metrics["items"].each do |test_suite|
            UI.message("Test Suite: #{test_suite["test_counts"]["total"]} tests, #{test_suite["test_counts"]["fail"]} failures")
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