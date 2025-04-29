require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CREATED_SCHEDULE_ID = :CIRCLECI_CREATED_SCHEDULE_ID
    end

    class CircleciCreatePipelineScheduleAction < Action
      def self.run(params)
        UI.message("Creating CircleCI pipeline schedule via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        name = params[:name]
        description = params[:description]
        attribution_actor = params[:attribution_actor]
        parameters = params[:parameters] || {}
        timetable = params[:timetable]
        branch = params[:branch]

        # Create request body
        body = {
          name: name,
          description: description,
          attribution_actor: attribution_actor,
          parameters: parameters,
          timetable: timetable
        }

        # Add branch if specified
        body[:branch] = branch if branch
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/schedule", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CREATED_SCHEDULE_ID] = result["id"]
        
        UI.success("Successfully created pipeline schedule '#{name}' with ID #{result["id"]}")
        
        return result
      end

      def self.description
        "Creates a new pipeline schedule for a CircleCI project using API v2"
      end

      def self.details
        "This action creates a new pipeline schedule for a specific CircleCI project using the CircleCI API v2. The schedule determines when pipelines will be automatically triggered."
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
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "CIRCLE_CI_SCHEDULE_NAME",
                                       description: "Name of the schedule",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "CIRCLE_CI_SCHEDULE_DESCRIPTION",
                                       description: "Description of the schedule",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :attribution_actor,
                                       env_name: "CIRCLE_CI_ATTRIBUTION_ACTOR",
                                       description: "The attribution actor who will run the scheduled pipeline (e.g., 'current' for the current user)",
                                       is_string: true,
                                       default_value: "current",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :parameters,
                                       env_name: "CIRCLE_CI_SCHEDULE_PARAMETERS",
                                       description: "Pipeline parameters, must match parameters defined in the pipeline configuration",
                                       is_string: false,
                                       default_value: {},
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :timetable,
                                       env_name: "CIRCLE_CI_SCHEDULE_TIMETABLE",
                                       description: "Timetable hash defining when the schedule should run (e.g., {per_hour: 1, hours_of_day: [0, 12], days_of_week: [1, 3, 5]})",
                                       is_string: false,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "CIRCLE_CI_SCHEDULE_BRANCH",
                                       description: "The branch to trigger a pipeline on",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CREATED_SCHEDULE_ID', 'The ID of the created pipeline schedule']
        ]
      end

      def self.return_value
        "Returns the full API response including the created schedule's details."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_pipeline_schedule(
            project_slug: "github/myorg/myrepo",
            name: "Nightly Build",
            description: "Runs every night at midnight",
            timetable: {
              per_hour: 1,
              hours_of_day: [0],
              days_of_week: [1, 2, 3, 4, 5]
            },
            branch: "main",
            parameters: {
              "deploy_env" => "staging"
            }
          )',
          'circleci_create_pipeline_schedule(
            project_slug: "github/myorg/myrepo",
            name: "Weekly Release",
            description: "Runs every Friday at 2pm",
            timetable: {
              per_hour: 1,
              hours_of_day: [14],
              days_of_week: [5]
            },
            branch: "release"
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