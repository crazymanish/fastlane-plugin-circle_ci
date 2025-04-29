require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PROJECT_COLLABORATOR = :CIRCLECI_PROJECT_COLLABORATOR
    end

    class CircleciAddProjectCollaboratorAction < Action
      def self.run(params)
        UI.message("Adding collaborator to CircleCI project via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        username = params[:username]
        
        # Construct the request body
        body = {
          id: username
        }
        
        # Make API request
        endpoint = "project/#{project_slug}/user/#{username}"
        result = Helper::CircleCiHelper.post_v2(endpoint, api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PROJECT_COLLABORATOR] = result
        
        UI.success("Successfully added collaborator #{username} to project")
        
        return result
      end

      def self.description
        "Adds a user as a collaborator to a CircleCI project using API v2"
      end

      def self.details
        "This action adds a user as a collaborator to a CircleCI project using the CircleCI API v2. " +
        "The collaborator will be granted access to view and manage the project based on their role permissions."
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
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "CIRCLE_CI_COLLABORATOR_USERNAME",
                                       description: "The username of the user to add as a collaborator",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PROJECT_COLLABORATOR', 'A hash containing the collaborator data']
        ]
      end

      def self.return_value
        "Returns a hash containing the collaborator information and their role in the project."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_add_project_collaborator(
            project_slug: "github/myorg/myrepo",
            username: "new-collaborator"
          )',
          '# Add a collaborator and verify they were added
          collaborator = circleci_add_project_collaborator(
            project_slug: "github/myorg/myrepo",
            username: "new-collaborator"
          )
          
          UI.message("Added #{collaborator["id"]} with role #{collaborator["role"]}")'
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