require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciRerunWorkflowAction < Action
      def self.run(params)
        UI.message("Rerunning CircleCI workflow via API v2...")
        
        api_token = params[:api_token]
        workflow_id = params[:workflow_id]
        from_failed = params[:from_failed]
        sparse_tree = params[:sparse_tree]
        
        # Create request body
        body = {}
        body[:from_failed] = from_failed unless from_failed.nil?
        body[:sparse_tree] = sparse_tree unless sparse_tree.nil?
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("workflow/#{workflow_id}/rerun", api_token, body)
        
        UI.success("Successfully reran workflow with ID #{workflow_id}")
        
        return result
      end

      def self.description
        "Reruns a workflow in CircleCI using API v2"
      end

      def self.details
        "This action reruns a specific workflow in CircleCI using the CircleCI API v2. You can choose to rerun the entire workflow or just the failed jobs."
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
                                       description: "The ID of the workflow to rerun",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :from_failed,
                                       env_name: "CIRCLE_CI_WORKFLOW_FROM_FAILED",
                                       description: "Whether to rerun just the failed jobs (true) or all jobs (false)",
                                       is_string: false,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sparse_tree,
                                       env_name: "CIRCLE_CI_WORKFLOW_SPARSE_TREE",
                                       description: "If rerunning failed jobs, whether to rerun them as a sparse tree of only the failed jobs",
                                       is_string: false,
                                       default_value: false,
                                       optional: true)
        ]
      end

      def self.return_value
        "Returns the API response with workflow rerun information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_rerun_workflow(
            workflow_id: "1234-5678-90ab-cdef"
          )',
          'circleci_rerun_workflow(
            workflow_id: "1234-5678-90ab-cdef",
            from_failed: false  # Rerun all jobs in the workflow
          )',
          'circleci_rerun_workflow(
            workflow_id: "1234-5678-90ab-cdef",
            from_failed: true,
            sparse_tree: true  # Rerun only the failed jobs and their upstream dependencies
          )'
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