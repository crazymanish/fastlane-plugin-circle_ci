require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PROJECT = :CIRCLECI_PROJECT
    end

    class CircleciCreateProjectAction < Action
      def self.run(params)
        UI.message("Creating CircleCI project via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/follow", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PROJECT] = result
        
        UI.success("Successfully created CircleCI project #{project_slug}")
        
        return result
      end

      def self.description
        "Creates a new CircleCI project using API v2"
      end

      def self.details
        "This action creates a new CircleCI project by following a repository using the CircleCI API v2. This makes the repository available for building on CircleCI."
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
          ['CIRCLECI_PROJECT', 'A hash containing the created project details']
        ]
      end

      def self.return_value
        "Returns a hash containing the created project details."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_project(
            project_slug: "github/myorg/new-repo"
          )',
          '# Create a new CircleCI project and immediately trigger a build
          project = circleci_create_project(
            project_slug: "github/myorg/new-repo"
          )
          
          # Trigger first pipeline
          pipeline = circleci_trigger_pipeline(
            project_slug: "github/myorg/new-repo",
            branch: "main"
          )
          
          UI.message("Started pipeline ##{pipeline["number"]} for the new project")
          
          # Wait for the pipeline to complete
          circleci_wait_for_pipeline(
            project_slug: "github/myorg/new-repo",
            pipeline_id: pipeline["id"],
            timeout: 1800 # 30 minutes
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