require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_ALL_PIPELINES = :CIRCLECI_ALL_PIPELINES
    end

    class CircleciListAllPipelinesAction < Action
      def self.run(params)
        UI.message("Getting all CircleCI pipelines via API v2...")
        
        api_token = params[:api_token]
        org_slug = params[:org_slug]
        
        query_params = {}
        query_params["org-slug"] = org_slug if org_slug
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("pipeline", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_ALL_PIPELINES] = result
        
        UI.success("Successfully retrieved all pipelines")
        
        return result
      end

      def self.description
        "Gets a list of all pipelines across projects using CircleCI API v2"
      end

      def self.details
        "This action retrieves all pipelines for the most recently built projects (max 250) you follow in an organization using the CircleCI API v2."
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
          FastlaneCore::ConfigItem.new(key: :org_slug,
                                       description: "The organization slug (optional, for filtering by organization)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_ALL_PIPELINES', 'A hash containing all pipelines information']
        ]
      end

      def self.return_value
        "Returns a hash containing information about all pipelines."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_list_all_pipelines',
          'pipelines = circleci_list_all_pipelines(
            org_slug: "gh/MyOrg"
          )
          
          # Process the pipelines
          pipelines["items"].each do |pipeline|
            UI.message("Pipeline ID: #{pipeline["id"]}, Created: #{pipeline["created_at"]}")
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