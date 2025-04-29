require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_JOB_DETAILS = :CIRCLECI_JOB_DETAILS
    end

    class CircleciGetJobDetailsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI job details via API v2...")
        
        api_token = params[:api_token]
        job_number = params[:job_number]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/job/#{job_number}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_JOB_DETAILS] = result
        
        UI.success("Successfully retrieved job details for job #{job_number}")
        
        return result
      end

      def self.description
        "Gets detailed information about a CircleCI job using API v2"
      end

      def self.details
        "This action retrieves detailed information about a specific CircleCI job using the CircleCI API v2, including status, duration, and executor information."
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
                                       description: "The number of the job to get details for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_JOB_DETAILS', 'A hash containing the job details']
        ]
      end

      def self.return_value
        "Returns a hash containing detailed job information including status, duration, and executor information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_job_details(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )',
          'job_details = circleci_get_job_details(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )
          
          if job_details["status"] == "success"
            duration_seconds = job_details["duration"]
            puts "Job completed successfully in #{duration_seconds} seconds"
            
            # Calculate job cost
            credits_per_minute = 7 # Example value, depends on your plan and resource class
            minutes = (duration_seconds / 60.0).ceil
            cost = minutes * credits_per_minute
            puts "Estimated job cost: #{cost} credits"
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