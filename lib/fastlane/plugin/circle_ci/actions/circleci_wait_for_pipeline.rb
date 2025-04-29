require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WAIT_RESULT = :CIRCLECI_WAIT_RESULT
    end

    class CircleciWaitForPipelineAction < Action
      def self.run(params)
        UI.message("Waiting for CircleCI pipeline to complete via API v2...")
        
        api_token = params[:api_token]
        pipeline_id = params[:pipeline_id]
        timeout = params[:timeout]
        poll_interval = params[:poll_interval]
        
        start_time = Time.now
        timeout_time = start_time + timeout
        
        loop do
          # Check if we've timed out
          if Time.now > timeout_time
            UI.error("Timed out waiting for pipeline to complete after #{timeout} seconds")
            return { 
              success: false, 
              status: "timeout", 
              pipeline_id: pipeline_id,
              waited: Time.now - start_time
            }
          end
          
          # Get pipeline info
          result = Helper::CircleCiHelper.get_v2("pipeline/#{pipeline_id}", api_token)
          
          UI.verbose("Pipeline state: #{result["state"]}")
          
          # Return if the pipeline has reached a terminal state
          if ["success", "failed", "error", "canceled"].include?(result["state"])
            UI.success("Pipeline completed with state: #{result["state"]}")
            
            wait_result = { 
              success: result["state"] == "success",
              status: result["state"],
              pipeline_id: pipeline_id,
              waited: Time.now - start_time
            }
            
            # Store values in lane context
            Actions.lane_context[SharedValues::CIRCLECI_WAIT_RESULT] = wait_result
            
            return wait_result
          end
          
          # Wait before polling again
          UI.message("Pipeline #{pipeline_id} is still running (state: #{result["state"]}), waiting #{poll_interval} seconds...")
          sleep(poll_interval)
        end
      end

      def self.description
        "Waits for a CircleCI pipeline to complete using API v2"
      end

      def self.details
        "This action waits for a specific CircleCI pipeline to reach a terminal state (success, failed, error, or canceled) using the CircleCI API v2."
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
                                       description: "The ID of the pipeline to wait for",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: "CIRCLE_CI_WAIT_TIMEOUT",
                                       description: "Maximum time to wait for the pipeline to complete (in seconds)",
                                       is_string: false,
                                       default_value: 1800, # 30 minutes
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :poll_interval,
                                       env_name: "CIRCLE_CI_POLL_INTERVAL",
                                       description: "Time between status checks (in seconds)",
                                       is_string: false,
                                       default_value: 30,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_WAIT_RESULT', 'A hash containing the wait result including success status and pipeline state']
        ]
      end

      def self.return_value
        "Returns a hash containing the wait result including success status, final pipeline state, pipeline ID, and time waited."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_wait_for_pipeline(
            pipeline_id: "12345-6789-abcd-ef01"
          )',
          'circleci_wait_for_pipeline(
            pipeline_id: "12345-6789-abcd-ef01",
            timeout: 3600,        # Wait up to 1 hour
            poll_interval: 60     # Check every minute
          )',
          '# Trigger a pipeline and wait for it to complete
          pipeline = circleci_trigger_pipeline(
            project_slug: "github/myorg/myrepo",
            branch: "main"
          )
          
          result = circleci_wait_for_pipeline(
            pipeline_id: pipeline["id"]
          )
          
          if result[:success]
            UI.success("Pipeline completed successfully!")
          else
            UI.error("Pipeline failed with status: #{result[:status]}")
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