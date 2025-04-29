require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciSetEnvVarAction < Action
      def self.run(params)
        UI.message("Setting environment variable for CircleCI project via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        name = params[:name]
        value = params[:value]
        
        # Create request body
        body = {
          name: name,
          value: value
        }
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/envvar", api_token, body)
        
        UI.success("Successfully set environment variable '#{name}' for project #{project_slug}")
        
        return result
      end

      def self.description
        "Sets an environment variable for a CircleCI project using API v2"
      end

      def self.details
        "This action sets an environment variable for a specific CircleCI project using the CircleCI API v2."
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
                                       env_name: "CIRCLE_CI_ENV_VAR_NAME",
                                       description: "Name of the environment variable to set",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "CIRCLE_CI_ENV_VAR_VALUE",
                                       description: "Value of the environment variable to set",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns the API response containing the name and masked value of the set environment variable."
      end

      def self.authors
        ["crazymanish, "copilot""]
      end

      def self.example_code
        [
          'circleci_set_env_var(
            project_slug: "github/myorg/myrepo",
            name: "API_KEY",
            value: "secret-api-key"
          )',
          'circleci_set_env_var(
            project_slug: "github/myorg/myrepo",
            name: "DEPLOY_ENVIRONMENT",
            value: "production"
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