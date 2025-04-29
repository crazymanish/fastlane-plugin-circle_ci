require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeleteWebhookAction < Action
      def self.run(params)
        UI.message("Deleting CircleCI webhook via API v2...")
        
        api_token = params[:api_token]
        webhook_id = params[:webhook_id]
        
        # Make API request
        Helper::CircleCiHelper.delete_v2("webhook/#{webhook_id}", api_token)
        
        UI.success("Successfully deleted webhook with ID #{webhook_id}")
        
        return { success: true, webhook_id: webhook_id }
      end

      def self.description
        "Deletes a webhook from CircleCI using API v2"
      end

      def self.details
        "This action deletes a specific webhook from CircleCI using the CircleCI API v2."
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
          FastlaneCore::ConfigItem.new(key: :webhook_id,
                                       env_name: "CIRCLE_CI_WEBHOOK_ID",
                                       description: "The ID of the webhook to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with success status and the deleted webhook ID."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_webhook(
            webhook_id: "webhook-uuid"
          )',
          '# First get all webhooks, then delete a specific one
          webhooks = circleci_list_webhooks(
            scope_id: "project-uuid",
            scope_type: "project"
          )
          
          slack_webhook = webhooks.find { |webhook| webhook["name"].include?("Slack") }
          
          if slack_webhook
            circleci_delete_webhook(
              webhook_id: slack_webhook["id"]
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