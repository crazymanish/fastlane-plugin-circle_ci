require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciCancelWorkflowAction < Action
      def self.run(params)
        UI.message("Canceling CircleCI workflow via API v2...")
        
        api_token = params[:api_token]
        workflow_id = params[:workflow_id]
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("workflow/#{workflow_id}/cancel", api_token)
        
        UI.success("Successfully canceled workflow with ID #{workflow_id}")
        
        return { success: true, message: result["message"] }
      end

      def self.description
        "Cancels a running workflow in CircleCI using API v2"
      end

      def self.details
        "This action cancels a specific running workflow in CircleCI using the CircleCI API v2."
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
                                       description: "The ID of the workflow to cancel",
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
          'circleci_cancel_workflow(
            workflow_id: "1234-5678-90ab-cdef"
          )',
          '# First get workflows for a pipeline, then cancel a specific one
          workflows = circleci_get_pipeline_workflows(
            pipeline_id: "some-pipeline-id"
          )
          
          workflows.each do |workflow|
            if workflow["status"] == "running" && workflow["name"] == "build-and-test"
              circleci_cancel_workflow(
                workflow_id: workflow["id"]
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