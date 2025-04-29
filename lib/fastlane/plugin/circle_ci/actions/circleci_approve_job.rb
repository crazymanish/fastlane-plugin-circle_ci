require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciApproveJobAction < Action
      def self.run(params)
        UI.message("Approving CircleCI job via API v2...")
        
        api_token = params[:api_token]
        approval_request_id = params[:approval_request_id]
        
        # Make API request with empty body as required by the API
        result = Helper::CircleCiHelper.post_v2("workflow/#{approval_request_id}/approve", api_token, {})
        
        UI.success("Successfully approved job with approval request ID #{approval_request_id}")
        
        return { success: true, message: "Job approved" }
      end

      def self.description
        "Approves a pending approval job in a CircleCI workflow using API v2"
      end

      def self.details
        "This action approves a pending approval job in a CircleCI workflow using the CircleCI API v2. This is useful for automated approval of deployment jobs."
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
          FastlaneCore::ConfigItem.new(key: :approval_request_id,
                                       env_name: "CIRCLE_CI_APPROVAL_REQUEST_ID",
                                       description: "The ID of the approval request to approve",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with success status and a message."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_approve_job(
            approval_request_id: "approval-request-uuid"
          )',
          '# First get workflows for a pipeline, then find and approve any pending approval jobs
          workflows = circleci_get_pipeline_workflows(
            pipeline_id: "some-pipeline-id"
          )
          
          # For each workflow
          workflows.each do |workflow|
            # Get jobs for the workflow
            jobs = circleci_get_workflow_jobs(
              workflow_id: workflow["id"]
            )
            
            # Find approval jobs that are on_hold
            approval_jobs = jobs.select { |job| job["type"] == "approval" && job["status"] == "on_hold" }
            
            # Approve each job
            approval_jobs.each do |job|
              circleci_approve_job(
                approval_request_id: job["id"]
              )
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