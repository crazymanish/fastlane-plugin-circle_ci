require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_ENV_VARS = :CIRCLECI_ENV_VARS
    end

    class CircleciGetEnvVarsAction < Action
      def self.run(params)
        UI.message("Getting environment variables for CircleCI project via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/envvar", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_ENV_VARS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} environment variables for project #{project_slug}")
        
        return result["items"]
      end

      def self.description
        "Gets environment variables for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves all environment variables for a specific CircleCI project using the CircleCI API v2. Note that values are not included in the response for security reasons."
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
          ['CIRCLECI_ENV_VARS', 'An array of environment variable data for the project']
        ]
      end

      def self.return_value
        "Returns an array of environment variable data including names."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_env_vars(
            project_slug: "github/myorg/myrepo"
          )',
          'env_vars = circleci_get_env_vars(
            project_slug: "github/myorg/myrepo"
          )
          
          # Check if a specific environment variable exists
          has_api_key = env_vars.any? { |var| var["name"] == "API_KEY" }
          puts "API key is #{has_api_key ? "set" : "not set"} for this project"'
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