require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_WORKFLOWS = :CIRCLECI_PIPELINE_WORKFLOWS
    end

    class CircleciGetPipelineWorkflowsAction < Action
      def self.run(params)
        UI.message("Getting workflows for CircleCI pipeline via API v2...")
        
        api_token = params[:api_token]
        pipeline_id = params[:pipeline_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("pipeline/#{pipeline_id}/workflow", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_WORKFLOWS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} workflows for pipeline #{pipeline_id}")
        
        return result["items"]
      end

      def self.description
        "Gets workflows for a CircleCI pipeline using API v2"
      end

      def self.details
        "This action retrieves all workflows for a specific CircleCI pipeline using the CircleCI API v2, including status, IDs, and names."
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
          FastlaneCore::ConfigItem.new(key: :pipeline_id,
                                       env_name: "CIRCLE_CI_PIPELINE_ID",
                                       description: "The ID of the pipeline to get workflows for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_WORKFLOWS', 'An array of workflow data for the pipeline']
        ]
      end

      def self.return_value
        "Returns an array of workflow data including IDs, names, and status information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_pipeline_workflows(
            pipeline_id: "pipeline-uuid"
          )',
          'workflows = circleci_get_pipeline_workflows(
            pipeline_id: "pipeline-uuid"
          )
          
          # Find workflows by status
          running_workflows = workflows.select { |w| w["status"] == "running" }
          
          if running_workflows.any?
            UI.message("There are #{running_workflows.count} workflows still running in this pipeline")
            running_workflows.each do |workflow|
              puts "  - #{workflow["name"]}: #{workflow["status"]}"
            end
          end
          
          # Find a specific workflow
          deploy_workflow = workflows.find { |w| w["name"] == "deploy" }
          if deploy_workflow
            # Get jobs for the deploy workflow
            jobs = circleci_get_workflow_jobs(
              workflow_id: deploy_workflow["id"]
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