require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeleteEnvVarAction < Action
      def self.run(params)
        UI.message("Deleting environment variable for CircleCI project via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        name = params[:name]
        
        # Make API request
        Helper::CircleCiHelper.delete_v2("project/#{project_slug}/envvar/#{name}", api_token)
        
        UI.success("Successfully deleted environment variable '#{name}' for project #{project_slug}")
        
        return { success: true, name: name }
      end

      def self.description
        "Deletes an environment variable for a CircleCI project using API v2"
      end

      def self.details
        "This action deletes an environment variable for a specific CircleCI project using the CircleCI API v2."
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
                                       description: "Name of the environment variable to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with success status and name of the deleted environment variable."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_env_var(
            project_slug: "github/myorg/myrepo",
            name: "API_KEY"
          )',
          'circleci_delete_env_var(
            project_slug: "github/myorg/myrepo",
            name: "DEPLOY_ENVIRONMENT"
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