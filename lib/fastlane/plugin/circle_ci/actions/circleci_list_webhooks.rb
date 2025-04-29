require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_WEBHOOKS = :CIRCLECI_WEBHOOKS
    end

    class CircleciListWebhooksAction < Action
      def self.run(params)
        UI.message("Listing CircleCI webhooks via API v2...")
        
        api_token = params[:api_token]
        scope_id = params[:scope_id]
        scope_type = params[:scope_type]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("webhook", api_token, {
          "scope-id" => scope_id,
          "scope-type" => scope_type
        })
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_WEBHOOKS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} webhooks")
        
        return result["items"]
      end

      def self.description
        "Lists webhooks for a CircleCI project or organization using API v2"
      end

      def self.details
        "This action retrieves all webhooks defined for a specific CircleCI project or organization using the CircleCI API v2."
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
          FastlaneCore::ConfigItem.new(key: :scope_id,
                                       env_name: "CIRCLE_CI_WEBHOOK_SCOPE_ID",
                                       description: "The ID of the project or organization to list webhooks for",
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
          ['CIRCLECI_WEBHOOKS', 'An array of webhook data']
        ]
      end

      def self.return_value
        "Returns an array of webhook data including IDs, URLs, and event types."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_list_webhooks(
            scope_id: "project-uuid",
            scope_type: "project"
          )',
          'circleci_list_webhooks(
            scope_id: "organization-uuid",
            scope_type: "organization"
          )',
          'webhooks = circleci_list_webhooks(
            scope_id: "project-uuid",
            scope_type: "project"
          )
          
          # Check if a specific webhook exists
          has_slack_webhook = webhooks.any? { |webhook| webhook["url"].include?("hooks.slack.com") }
          puts "Slack webhook is #{has_slack_webhook ? "configured" : "not configured"}"'
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