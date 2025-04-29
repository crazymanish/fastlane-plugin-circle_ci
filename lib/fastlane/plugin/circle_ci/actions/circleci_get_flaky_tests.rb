require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_FLAKY_TESTS = :CIRCLECI_FLAKY_TESTS
    end

    class CircleciGetFlakyTestsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI flaky tests via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("insights/#{project_slug}/flaky-tests", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_FLAKY_TESTS] = result
        
        UI.success("Successfully retrieved flaky tests data for #{project_slug}")
        
        return result
      end

      def self.description
        "Gets flaky tests information for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves information about flaky tests for a specific CircleCI project using the CircleCI API v2. This is useful for monitoring test health and improving CI reliability."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_FLAKY_TESTS', 'A hash containing flaky tests information']
        ]
      end

      def self.return_value
        "Returns a hash containing flaky tests information including average test count, most failed tests, and slowest tests."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_flaky_tests(
            project_slug: "gh/MyOrg/my-project"
          )',
          'flaky_tests = circleci_get_flaky_tests(
            project_slug: "gh/MyOrg/my-project"
          )
          
          # Take action based on flaky tests
          if flaky_tests["most_failed_tests"].any?
            UI.important("Found #{flaky_tests["most_failed_tests"].count} flaky tests that need attention")
            flaky_tests["most_failed_tests"].each do |test|
              puts "  - #{test["test_name"]}: Failed #{test["times_flaked"]} times"
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