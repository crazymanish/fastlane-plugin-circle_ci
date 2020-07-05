require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      TRIGGER_CIRCLE_CI_JOB_RESULT = :TRIGGER_CIRCLE_CI_JOB_RESULT
    end

    class TriggerCircleCiJobAction < Action
      def self.run(params)
        token = params[:api_token]
        vcs = params[:vcs_type]
        name = params[:user_name]
        project = params[:project_name]
        branch = params[:branch_name]
        parameters = params[:build_parameters]

        parameters[:CIRCLE_JOB] = params[:job_name]
        # Remove any kv-pairs in the hash for which the value is nil (to not send keys with "null" as value).
        parameters.delete_if { |k, v| v.nil? }
        parameters = parameters.to_json

        uri = "https://circleci.com"
        api_url = "api/v1.1/project/#{vcs}/#{name}/#{project}/tree/#{branch}"
        curl_command = "curl -X POST -u #{token}: -H 'Content-Type: application/json' -d '{\"build_parameters\": #{parameters}}' -s #{uri}/#{api_url}"

        result = Actions::sh("#{curl_command}", log: false)

        Actions.lane_context[SharedValues::TRIGGER_CIRCLE_CI_JOB_RESULT] = result
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Triggers a new CircleCI Job"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_API_TOKEN",
                                       description: "API Token for CircleCI API",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :job_name,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_NAME",
                                       description: "CircleCI job name usually defined under '.circleci/config.yml' file",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :vcs_type,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_VCS_TYPE",
                                       description: "CircleCI vcs type i.e github/bitbucket",
                                       is_string: true,
                                       default_value: "github"),
          FastlaneCore::ConfigItem.new(key: :user_name,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_USER_NAME",
                                       description: "CircleCI project repo user name i.e For github repo 'crazymanish/some_repo_name', user_name will be 'crazymanish'",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_PROJECT_NAME",
                                       description: "CircleCI project repo project name i.e For github repo 'crazymanish/some_repo_name', project_name will be 'some_repo_name'",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_BRANCH_NAME",
                                       description: "CircleCI branch name",
                                       is_string: true,
                                       default_value: "master"),
          FastlaneCore::ConfigItem.new(key: :build_parameters,
                                       env_name: "FL_TRIGGER_CIRCLE_CI_JOB_BUILD_PARAMETERS",
                                       description: "Add additional build parameters, build_parameters must be a hash containing any key with any value",
                                       default_value: {},
                                       is_string: false)
        ]
      end

      def self.output
        [
          ['TRIGGER_CIRCLE_CI_JOB_RESULT', 'Api response of new job trigger']
        ]
      end

      def self.return_value
        "Returns the api response of new job trigger"
      end

      def self.example_code
        [
          'trigger_circle_ci_job(
            job_name: "some_job_name",
            user_name: "crazymanish",
            project_name: "some_repo_name",
            branch_name: "some_git_branch",
            build_parameters: {  # Optional, lets you specify any number of your own build parameters.
              "RUN_EXTRA_TESTS" => "true",
              "RUN_EXTRA_SOMETHING" => "something"
            }
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
