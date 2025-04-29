require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_PIPELINE_ID = :CIRCLECI_PIPELINE_ID
      CIRCLECI_PIPELINE_NUMBER = :CIRCLECI_PIPELINE_NUMBER
      CIRCLECI_PIPELINE_URL = :CIRCLECI_PIPELINE_URL
    end

    class CircleciTriggerPipelineAction < Action
      def self.run(params)
        UI.message("Triggering CircleCI pipeline via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        branch = params[:branch]
        parameters = params[:parameters] || {}
        
        # Create request body
        body = {
          branch: branch
        }

        # Add parameters if they exist
        body[:parameters] = parameters unless parameters.empty?
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/pipeline", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_ID] = result["id"]
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_NUMBER] = result["number"]
        
        # Create pipeline URL
        vcs_info = project_slug.split('/')
        pipeline_url = "https://app.circleci.com/pipelines/#{vcs_info[0]}/#{vcs_info[1]}/#{vcs_info[2]}/#{result["number"]}"
        Actions.lane_context[SharedValues::CIRCLECI_PIPELINE_URL] = pipeline_url
        
        UI.success("Successfully triggered CircleCI pipeline ##{result["number"]} with ID #{result["id"]}")
        UI.success("Pipeline URL: #{pipeline_url}")
        
        return result
      end

      def self.description
        "Triggers a CircleCI pipeline using API v2"
      end

      def self.details
        "This action triggers a CircleCI pipeline using the CircleCI API v2. It allows you to specify branch and parameters for the pipeline run."
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
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "CIRCLE_CI_BRANCH",
                                       description: "The branch to trigger a pipeline on",
                                       is_string: true,
                                       default_value: "main",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :parameters,
                                       env_name: "CIRCLE_CI_PIPELINE_PARAMETERS",
                                       description: "Pipeline parameters, must match parameters defined in the pipeline configuration",
                                       is_string: false,
                                       default_value: {},
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_PIPELINE_ID', 'The ID of the triggered pipeline'],
          ['CIRCLECI_PIPELINE_NUMBER', 'The number of the triggered pipeline'],
          ['CIRCLECI_PIPELINE_URL', 'The URL of the triggered pipeline']
        ]
      end

      def self.return_value
        "Returns the full API response from CircleCI API"
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_trigger_pipeline(
            project_slug: "github/myorg/myrepo",
            branch: "main",
            parameters: {
              "deploy_env" => "staging",
              "run_integration_tests" => true
            }
          )',
          'circleci_trigger_pipeline(
            project_slug: "github/myorg/myrepo",
            branch: "feature/my-branch"
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