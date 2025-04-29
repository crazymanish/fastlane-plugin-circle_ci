require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciCancelJobAction < Action
      def self.run(params)
        UI.message("Canceling CircleCI job via API v2...")
        
        api_token = params[:api_token]
        job_number = params[:job_number]
        project_slug = params[:project_slug]
        
        # Make API request with empty body as required by the API
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/job/#{job_number}/cancel", api_token, {})
        
        UI.success("Successfully canceled job #{job_number} in project #{project_slug}")
        
        return { success: true, message: result["message"] }
      end

      def self.description
        "Cancels a running job in CircleCI using API v2"
      end

      def self.details
        "This action cancels a specific running job in CircleCI using the CircleCI API v2. This provides more granular control than canceling an entire workflow."
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
          FastlaneCore::ConfigItem.new(key: :job_number,
                                       env_name: "CIRCLE_CI_JOB_NUMBER",
                                       description: "The number of the job to cancel",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with success status and the response message."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_cancel_job(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )',
          '# First get jobs for a workflow, then cancel a specific one
          jobs = circleci_get_workflow_jobs(
            workflow_id: "workflow-id"
          )
          
          # Find a job by name and cancel it if it\'s running
          test_job = jobs.find { |job| job["name"] == "run-tests" && job["status"] == "running" }
          
          if test_job
            circleci_cancel_job(
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