require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PROJECT_CONFIG = :CIRCLECI_PROJECT_CONFIG
    end

    class CircleciGetProjectConfigAction < Action
      def self.run(params)
        UI.message("Getting CircleCI project configuration via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/config", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PROJECT_CONFIG] = result
        
        UI.success("Successfully retrieved configuration for project #{project_slug}")
        
        return result
      end

      def self.description
        "Gets the configuration for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves configuration information for a specific CircleCI project using the CircleCI API v2, including compiled YAML configuration."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PROJECT_CONFIG', 'A hash containing the project configuration details']
        ]
      end

      def self.return_value
        "Returns a hash containing project configuration information including compiled YAML configuration."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_project_config(
            project_slug: "github/myorg/myrepo"
          )',
          'config = circleci_get_project_config(
            project_slug: "github/myorg/myrepo"
          )
          
          # Check the configuration source type
          if config["source"] == "local"
            UI.message("Project uses a local config file")
          else
            UI.message("Project uses a #{config["source"]} config")
          end
          
          # Get compiled configuration
          compiled_config = config["compiled"]
          
          # Look for specific workflows or jobs
          if compiled_config && compiled_config.include?("publish-workflow")
            UI.message("Found publish workflow in the configuration")
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