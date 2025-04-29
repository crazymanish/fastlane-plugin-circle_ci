require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_SCHEDULES = :CIRCLECI_PIPELINE_SCHEDULES
    end

    class CircleciListPipelineSchedulesAction < Action
      def self.run(params)
        UI.message("Listing CircleCI pipeline schedules via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/schedule", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_SCHEDULES] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} pipeline schedules for project #{project_slug}")
        
        return result["items"]
      end

      def self.description
        "Lists pipeline schedules for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves all pipeline schedules for a specific CircleCI project using the CircleCI API v2."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_SCHEDULES', 'An array of pipeline schedule data for the project']
        ]
      end

      def self.return_value
        "Returns an array of pipeline schedule data including IDs, names, and schedule details."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_list_pipeline_schedules(
            project_slug: "github/myorg/myrepo"
          )',
          'schedules = circleci_list_pipeline_schedules(
            project_slug: "github/myorg/myrepo"
          )
          
          # Find a specific schedule by name
          nightly_build = schedules.find { |schedule| schedule["name"] == "Nightly Build" }
          
          if nightly_build
            puts "Nightly build schedule ID: #{nightly_build["id"]}"
            puts "Schedule: #{nightly_build["description"]}"
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