require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeletePipelineScheduleAction < Action
      def self.run(params)
        UI.message("Deleting CircleCI pipeline schedule via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        schedule_id = params[:schedule_id]
        
        # Make API request
        Helper::CircleCiHelper.delete_v2("project/#{project_slug}/schedule/#{schedule_id}", api_token)
        
        UI.success("Successfully deleted pipeline schedule with ID #{schedule_id}")
        
        return { success: true, schedule_id: schedule_id }
      end

      def self.description
        "Deletes a pipeline schedule for a CircleCI project using API v2"
      end

      def self.details
        "This action deletes a specific pipeline schedule for a CircleCI project using the CircleCI API v2."
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
          FastlaneCore::ConfigItem.new(key: :schedule_id,
                                       env_name: "CIRCLE_CI_SCHEDULE_ID",
                                       description: "The ID of the schedule to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with success status and the deleted schedule ID."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_pipeline_schedule(
            project_slug: "github/myorg/myrepo",
            schedule_id: "0000-1111-2222-3333"
          )',
          '# First get all schedules, then delete a specific one
          schedules = circleci_list_pipeline_schedules(
            project_slug: "github/myorg/myrepo"
          )
          
          nightly_build = schedules.find { |schedule| schedule["name"] == "Nightly Build" }
          
          if nightly_build
            circleci_delete_pipeline_schedule(
              project_slug: "github/myorg/myrepo",
              schedule_id: nightly_build["id"]
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