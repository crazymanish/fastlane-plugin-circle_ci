require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_JOB_TESTS = :CIRCLECI_JOB_TESTS
    end

    class CircleciGetJobTestsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI job test results via API v2...")
        
        api_token = params[:api_token]
        job_number = params[:job_number]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/#{job_number}/tests", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_JOB_TESTS] = result
        
        UI.success("Successfully retrieved test results for job #{job_number}")
        
        return result
      end

      def self.description
        "Gets test metadata for a CircleCI job using API v2"
      end

      def self.details
        "This action retrieves test metadata for a specific CircleCI job using the CircleCI API v2. It returns detailed information about tests that were run as part of the job, including test names, classnames, results, and durations."
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
                                       description: "Project slug in the form of vcs-type/org-name/repo-name (e.g. github/myorg/myrepo)",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :job_number,
                                       env_name: "CIRCLE_CI_JOB_NUMBER",
                                       description: "The number of the job to get test results for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_JOB_TESTS', 'A hash containing the job test results']
        ]
      end

      def self.return_value
        "Returns a hash containing detailed test results information including test names, classnames, results, and durations."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_job_tests(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )',
          'test_results = circleci_get_job_tests(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )
          
          # Count failing tests
          failing_tests = test_results["items"].select { |test| test["result"] == "failure" }
          UI.message("#{failing_tests.count} failing tests found")
          
          # Print details of failing tests
          failing_tests.each do |test|
            UI.error("Failed: #{test["classname"]}##{test["name"]} (#{test["file"] || "unknown file"})")
            UI.error("Message: #{test["message"]}") if test["message"]
          end
          
          # Calculate total test duration
          total_duration_ms = test_results["items"].sum { |test| test["run_time"] || 0 }
          UI.message("Total test duration: #{total_duration_ms / 1000.0} seconds")'
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