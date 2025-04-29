require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WORKFLOW = :CIRCLECI_WORKFLOW
    end

    class CircleciGetWorkflowAction < Action
      def self.run(params)
        UI.message("Getting CircleCI workflow via API v2...")
        
        api_token = params[:api_token]
        workflow_id = params[:workflow_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("workflow/#{workflow_id}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WORKFLOW] = result
        
        UI.success("Successfully retrieved workflow #{workflow_id}")
        
        return result
      end

      def self.description
        "Gets information about a CircleCI workflow using API v2"
      end

      def self.details
        "This action retrieves detailed information about a specific CircleCI workflow using the CircleCI API v2, including status, created timestamp, pipeline ID, and project data."
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
                                       description: "The ID of the workflow to get information for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WORKFLOW', 'A hash containing the workflow details']
        ]
      end

      def self.return_value
        "Returns a hash containing detailed workflow information including status, created timestamp, and pipeline ID."
      end

      def self.authors
        ["crazymanish, "copilot""]
      end

      def self.example_code
        [
          'circleci_get_workflow(
            workflow_id: "workflow-uuid"
          )',
          'workflow = circleci_get_workflow(
            workflow_id: "workflow-uuid"
          )
          
          # Print workflow details
          puts "Workflow name: #{workflow["name"]}"
          puts "Status: #{workflow["status"]}"
          puts "Created at: #{workflow["created_at"]}"
          
          case workflow["status"]
          when "success"
            UI.success("Workflow completed successfully")
          when "running"
            UI.important("Workflow is still running")
            
            # Get workflow jobs
            jobs = circleci_get_workflow_jobs(
              workflow_id: workflow["id"]
            )
            
            running_jobs = jobs.select { |j| j["status"] == "running" }
            UI.message("There are #{running_jobs.count} jobs still running")
          when "failed"
            UI.error("Workflow failed")
            
            # Get workflow jobs to find failure
            jobs = circleci_get_workflow_jobs(
              workflow_id: workflow["id"]
            )
            
            failed_jobs = jobs.select { |j| j["status"] == "failed" }
            failed_jobs.each do |job|
              UI.error("Job #{job["name"]} failed")
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