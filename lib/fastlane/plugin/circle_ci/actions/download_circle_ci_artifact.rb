require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      DOWNLOAD_CIRCLE_CI_ARTIFACT_RESULT = :DOWNLOAD_CIRCLE_CI_ARTIFACT_RESULT
    end

    class DownloadCircleCiArtifactAction < Action
      def self.run(params)
        token = params[:api_token]
        url = params[:file_url]
        name = params[:output_file_name] || File.basename(url)

        curl_command = "curl -H 'Circle-Token: #{token}' -Ls -o /dev/null -w %{url_effective} #{url}"
        redirect_url = Actions::sh("#{curl_command}", log: false)

        curl_command = "curl -o #{name} '#{redirect_url}'"
        result = Actions::sh("#{curl_command}", log: false)

        Actions.lane_context[SharedValues::DOWNLOAD_CIRCLE_CI_ARTIFACT_RESULT] = result
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download the CircleCI artifact file."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_DOWNLOAD_CIRCLE_CI_ARTIFACT_API_TOKEN",
                                       description: "API Token for CircleCI API",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :file_url,
                                       env_name: "FL_DOWNLOAD_CIRCLE_CI_ARTIFACT_FILE_URL",
                                       description: "CircleCI artifact file url",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :output_file_name,
                                       env_name: "FL_DOWNLOAD_CIRCLE_CI_ARTIFACT_OUTPUT_FILE_NAME",
                                       description: "CircleCI artifact output file name",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['DOWNLOAD_CIRCLE_CI_ARTIFACT_RESULT', 'Output of the downloaded artifact']
        ]
      end

      def self.return_value
        "Returns the output of the downloaded artifact."
      end

      def self.example_code
        [
          'download_circle_ci_artifact(file_url: "circleci artifact file url")',
          'download_circle_ci_artifact(
            api_token: ENV["CIRCLE_CI_API_TOKEN"],
            file_url: "circleci artifact file url"
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
