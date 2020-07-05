require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      GET_CIRCLE_CI_BUILD_STATUS_RESULT = :GET_CIRCLE_CI_BUILD_STATUS_RESULT
    end

    class GetCircleCiBuildStatusAction < Action
      def self.run(params)
        token = params[:api_token]
        vcs = params[:vcs_type]
        name = params[:user_name]
        project = params[:project_name]
        build = params[:build_number]

        uri = "https://circleci.com"
        api_url = "api/v1.1/project/#{vcs}/#{name}/#{project}/#{build}"
        curl_command = "curl -H 'Content-Type: application/json' -H 'Circle-Token: #{token}' -s #{uri}/#{api_url}"

        result = Actions::sh("#{curl_command}", log: false)

        Actions.lane_context[SharedValues::GET_CIRCLE_CI_BUILD_STATUS_RESULT] = result
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "CircleCI build status"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GET_CIRCLE_CI_BUILD_STATUS_API_TOKEN",
                                       description: "API Token for CircleCI API",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :vcs_type,
                                       env_name: "FL_GET_CIRCLE_CI_BUILD_STATUS_VCS_TYPE",
                                       description: "CircleCI vcs type i.e github/bitbucket",
                                       is_string: true,
                                       default_value: "github"),
          FastlaneCore::ConfigItem.new(key: :user_name,
                                       env_name: "FL_GET_CIRCLE_CI_BUILD_STATUS_USER_NAME",
                                       description: "CircleCI project repo user name i.e For github repo 'crazymanish/some_repo_name', user_name will be 'crazymanish'",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_GET_CIRCLE_CI_BUILD_STATUS_PROJECT_NAME",
                                       description: "CircleCI project repo project name i.e For github repo 'crazymanish/some_repo_name', project_name will be 'some_repo_name'",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_GET_CIRCLE_CI_BUILD_STATUS_BUILD_NUMBER",
                                       description: "CircleCI build number",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['GET_CIRCLE_CI_BUILD_STATUS_RESULT', 'CircleCI build status']
        ]
      end

      def self.return_value
        "Returns the CircleCI build status."
      end

      def self.example_code
        [
          'get_circle_ci_build_status(
            user_name: "crazymanish",
            project_name: "some_repo_name",
            build_number: "1234"
          )'
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
