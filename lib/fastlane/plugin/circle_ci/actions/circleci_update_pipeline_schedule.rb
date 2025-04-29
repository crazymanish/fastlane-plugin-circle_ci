require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_UPDATED_SCHEDULE = :CIRCLECI_UPDATED_SCHEDULE
    end

    class CircleciUpdatePipelineScheduleAction < Action
      def self.run(params)
        UI.message("Updating CircleCI pipeline schedule via API v2...")
        
        api_token = params[:api_token]
        schedule_id = params[:schedule_id]
        
        # Build the request body with only provided parameters
        body = {}
        body["description"] = params[:description] if params[:description]
        body["name"] = params[:name] if params[:name]
        body["parameters"] = params[:parameters] if params[:parameters]
        body["timetable"] = params[:timetable] if params[:timetable]
        body["attribution-actor"] = params[:attribution_actor] if params[:attribution_actor]
        body["active"] = params[:active] unless params[:active].nil?
        
        # Make API request
        result = Helper::CircleCiHelper.patch_v2("schedule/#{schedule_id}", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_UPDATED_SCHEDULE] = result
        
        UI.success("Successfully updated pipeline schedule with ID #{schedule_id}")
        
        return result
      end

      def self.description
        "Updates a pipeline schedule in CircleCI using API v2"
      end

      def self.details
        "This action updates an existing pipeline schedule in CircleCI using the CircleCI API v2. You can update various properties such as name, description, parameters, and timetable."
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
          FastlaneCore::ConfigItem.new(key: :schedule_id,
                                       description: "The UUID of the schedule to update",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       description: "Description of the schedule",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :name,
                                       description: "Name of the schedule",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :parameters,
                                       description: "Pipeline parameters (e.g. branch, tag)",
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :timetable,
                                       description: "Timetable definition for the schedule (e.g. hours, days-of-week, etc.)",
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :attribution_actor,
                                       description: "The attribution-actor field for the scheduled pipeline",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :active,
                                       description: "Whether the schedule is active",
                                       is_string: false,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_UPDATED_SCHEDULE', 'A hash containing the updated schedule information']
        ]
      end

      def self.return_value
        "Returns a hash containing the updated schedule information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_update_pipeline_schedule(
            schedule_id: "8a3eb5ac-8666-451b-8bfc-1ee10e46c81e",
            name: "Updated Nightly Build",
            description: "Runs every night at midnight",
            parameters: {
              "branch" => "main"
            },
            active: false
          )',
          '# Get a more detailed timetable
          updated_schedule = circleci_update_pipeline_schedule(
            schedule_id: "8a3eb5ac-8666-451b-8bfc-1ee10e46c81e",
            timetable: {
              "per-hour" => 1,
              "hours-of-day" => [0, 12],
              "days-of-week" => ["MON", "WED", "FRI"],
              "time-zone" => "America/New_York"
            }
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