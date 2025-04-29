require 'fastlane/action'
require 'faraday'
require 'faraday/follow_redirects'
require 'fileutils'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDownloadArtifactAction < Action
      def self.run(params)
        UI.message("Downloading CircleCI artifact...")
        
        artifact_url = params[:artifact_url]
        destination_path = params[:destination_path]
        api_token = params[:api_token]
        
        # Ensure the directory exists
        FileUtils.mkdir_p(File.dirname(destination_path))
        
        # Configure Faraday
        conn = Faraday.new do |f|
          f.headers['Circle-Token'] = api_token if api_token
          f.response :follow_redirects
          f.adapter Faraday.default_adapter
        end
        
        # Download the file
        begin
          response = conn.get(artifact_url)
          
          if response.status >= 200 && response.status < 300
            # Write the response body to the destination file
            File.binwrite(destination_path, response.body)
            UI.success("Successfully downloaded artifact to #{destination_path}")
            return { success: true, path: destination_path }
          else
            UI.error("Failed to download artifact: HTTP #{response.status} - #{response.body}")
            return { success: false, error: "HTTP #{response.status}" }
          end
        rescue => e
          UI.error("Error downloading artifact: #{e.message}")
          return { success: false, error: e.message }
        end
      end

      def self.description
        "Downloads an artifact from CircleCI"
      end

      def self.details
        "This action downloads an artifact from CircleCI to a local path. It works with artifacts from the CircleCI API v2."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :artifact_url,
                                       env_name: "CIRCLE_CI_ARTIFACT_URL",
                                       description: "URL of the artifact to download",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                                       env_name: "CIRCLE_CI_ARTIFACT_DESTINATION",
                                       description: "Local path where the artifact should be saved",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CIRCLE_CI_API_TOKEN",
                                       description: "API Token for CircleCI API (only needed for private artifacts)",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["CIRCLE_CI_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: true)
        ]
      end

      def self.return_value
        "Returns a hash with success status and the path of the downloaded artifact or error information."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_download_artifact(
            artifact_url: "https://dl.circleci.com/private/output/job/12345/artifacts/0/path/to/artifact.zip",
            destination_path: "./artifacts/build.zip"
          )',
          '# First get artifacts, then download a specific one
          artifacts = circleci_get_job_artifacts(
            project_slug: "github/myorg/myrepo",
            job_number: "123"
          )
          
          # Find and download a test results artifact
          test_results = artifacts.find { |a| a["path"].end_with?("test-results.xml") }
          
          if test_results
            circleci_download_artifact(
              artifact_url: test_results["url"],
              destination_path: "./test-results/circle-results.xml"
            )
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