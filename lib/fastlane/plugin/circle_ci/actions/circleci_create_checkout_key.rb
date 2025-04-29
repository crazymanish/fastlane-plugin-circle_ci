require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CHECKOUT_KEY = :CIRCLECI_CHECKOUT_KEY
    end

    class CircleciCreateCheckoutKeyAction < Action
      def self.run(params)
        UI.message("Creating CircleCI project checkout key via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        key_type = params[:key_type]
        
        # Create the request body
        body = {
          "type" => key_type
        }
        
        # Make API request
        result = Helper::CircleCiHelper.post_v2("project/#{project_slug}/checkout-key", api_token, body)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CHECKOUT_KEY] = result
        
        UI.success("Successfully created checkout key (#{key_type}) for project #{project_slug}")
        
        return result
      end

      def self.description
        "Creates a new checkout key for a CircleCI project using API v2"
      end

      def self.details
        "This action creates a new checkout key for a specific CircleCI project using the CircleCI API v2. Checkout keys are used to check out code from your version control system. You can create either a 'deploy-key' or a 'github-user-key'."
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
          FastlaneCore::ConfigItem.new(key: :key_type,
                                       description: "The type of checkout key to create (deploy-key or github-user-key)",
                                       is_string: true,
                                       default_value: "deploy-key",
                                       verify_block: proc do |value|
                                         valid_types = ["deploy-key", "github-user-key"]
                                         UI.user_error!("Key type must be one of: #{valid_types.join(', ')}") unless valid_types.include?(value)
                                       end)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CHECKOUT_KEY', 'A hash containing the created checkout key information']
        ]
      end

      def self.return_value
        "Returns a hash containing the created checkout key information including type, fingerprint, and public key."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_create_checkout_key(
            project_slug: "gh/MyOrg/my-project",
            key_type: "deploy-key"
          )',
          'key = circleci_create_checkout_key(
            project_slug: "gh/MyOrg/my-project",
            key_type: "github-user-key"
          )
          
          # Use the created key information
          UI.message("Created key fingerprint: #{key["fingerprint"]}")'
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