require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CREATED_WEBHOOK_ID = :CIRCLECI_CREATED_WEBHOOK_ID
    end

    class CircleciCreateWebhookAction < Action
      def self.run(params)
        UI.message("Creating CircleCI webhook via API v2...")
        
        api_token = params[:api_token]
        name = params[:name]
        url = params[:url]
        events = params[:events]
        signing_secret = params[:signing_secret]
        verify_tls = params[:verify_tls]
        scope_id = params[:scope_id]
        scope_type = params[:scope_type]
        
        # Create request body
        body = {
          name: name,
          url: url,
          events: events,
          verify_tls: verify_tls,
          "signing-secret": signing_secret,
          scope: {
            id: scope_id,
            type: scope_type
          }
        }
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("webhook", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CREATED_WEBHOOK_ID] = result["id"]
        
        UI.success("Successfully created webhook '#{name}' with ID #{result["id"]}")
        
        return result
      end

      def self.description
        "Creates a new webhook for a CircleCI project or organization using API v2"
      end

      def self.details
        "This action creates a new webhook for a specific CircleCI project or organization using the CircleCI API v2. Webhooks allow external services to be notified of CircleCI events."
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
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "CIRCLE_CI_WEBHOOK_NAME",
                                       description: "Name of the webhook",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "CIRCLE_CI_WEBHOOK_URL",
                                       description: "URL to send the webhook to",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :events,
                                       env_name: "CIRCLE_CI_WEBHOOK_EVENTS",
                                       description: "Array of event types to trigger the webhook (e.g., ['workflow-completed', 'job-completed'])",
                                       is_string: false,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :signing_secret,
                                       env_name: "CIRCLE_CI_WEBHOOK_SIGNING_SECRET",
                                       description: "Secret used to verify webhook signatures",
                                       is_string: true,
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :verify_tls,
                                       env_name: "CIRCLE_CI_WEBHOOK_VERIFY_TLS",
                                       description: "Whether to verify TLS certificates when sending webhooks",
                                       is_string: false,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scope_id,
                                       env_name: "CIRCLE_CI_WEBHOOK_SCOPE_ID",
                                       description: "The ID of the project or organization to create the webhook for",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :scope_type,
                                       env_name: "CIRCLE_CI_WEBHOOK_SCOPE_TYPE",
                                       description: "The type of scope (either 'project' or 'organization')",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Scope type must be either 'project' or 'organization'") unless ['project', 'organization'].include?(value)
                                       end,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CREATED_WEBHOOK_ID', 'The ID of the created webhook']
        ]
      end

      def self.return_value
        "Returns the full API response including the created webhook's details."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_webhook(
            name: "Slack Notification",
            url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
            events: ["workflow-completed", "job-failed"],
            signing_secret: "your-secret-key",
            scope_id: "project-uuid",
            scope_type: "project"
          )',
          'circleci_create_webhook(
            name: "Deployment Notification",
            url: "https://example.com/deployment-webhook",
            events: ["workflow-completed"],
            signing_secret: "your-secret-key",
            verify_tls: false,
            scope_id: "organization-uuid",
            scope_type: "organization"
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