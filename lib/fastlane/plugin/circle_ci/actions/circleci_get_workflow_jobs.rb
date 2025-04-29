require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW_JOBS = :CIRCLECI_WORKFLOW_JOBS
    end

    class CircleciGetWorkflowJobsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI workflow jobs via API v2...")
        
        api_token = params[:api_token]
        workflow_id = params[:workflow_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("workflow/#{workflow_id}/job", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW_JOBS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} jobs for workflow #{workflow_id}")
        
        return result["items"]
      end

      def self.description
        "Gets jobs for a CircleCI workflow using API v2"
      end

      def self.details
        "This action retrieves all jobs for a specific CircleCI workflow using the CircleCI API v2, including status, job numbers, and names."
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
          FastlaneCore::ConfigItem.new(key: :workflow_id,
                                       env_name: "CIRCLE_CI_WORKFLOW_ID",
                                       description: "The ID of the workflow to get jobs for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW_JOBS', 'An array of job data for the workflow']
        ]
      end

      def self.return_value
        "Returns an array of job data including job numbers, names, and status information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_workflow_jobs(
            workflow_id: "workflow-uuid"
          )',
          'jobs = circleci_get_workflow_jobs(
            workflow_id: "workflow-uuid"
          )
          
          # Find jobs by status
          failed_jobs = jobs.select { |job| job["status"] == "failed" }
          
          if failed_jobs.any?
            UI.error("There are #{failed_jobs.count} failed jobs in this workflow")
            failed_jobs.each do |job|
              puts "  - #{job["name"]}: #{job["status"]}"
            end
          end
          
          # Find a specific job
          test_job = jobs.find { |job| job["name"] == "run-tests" }
          if test_job
            # Get detailed job information
            job_details = circleci_get_job_details(
              project_slug: "github/myorg/myrepo",
              job_number: test_job["job_number"]
            )
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