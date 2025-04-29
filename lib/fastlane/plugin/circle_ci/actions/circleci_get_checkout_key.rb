require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CHECKOUT_KEY_INFO = :CIRCLECI_CHECKOUT_KEY_INFO
    end

    class CircleciGetCheckoutKeyAction < Action
      def self.run(params)
        UI.message("Getting CircleCI project checkout key via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        fingerprint = params[:fingerprint]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/checkout-key/#{fingerprint}", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CHECKOUT_KEY_INFO] = result
        
        UI.success("Successfully retrieved checkout key with fingerprint #{fingerprint} for project #{project_slug}")
        
        return result
      end

      def self.description
        "Gets a specific checkout key for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves details for a specific checkout key for a CircleCI project using the CircleCI API v2. You need to provide the fingerprint of the key you want to retrieve."
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
          FastlaneCore::ConfigItem.new(key: :fingerprint,
                                       description: "The fingerprint of the checkout key to retrieve",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CHECKOUT_KEY_INFO', 'A hash containing the checkout key information']
        ]
      end

      def self.return_value
        "Returns a hash containing the checkout key information including type, fingerprint, and preferred status."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_checkout_key(
            project_slug: "gh/MyOrg/my-project",
            fingerprint: "c9:0b:1c:4f:d5:65:56:b9:ad:88:f9:81:2b:37:74:2f"
          )',
          'key_info = circleci_get_checkout_key(
            project_slug: "gh/MyOrg/my-project",
            fingerprint: "c9:0b:1c:4f:d5:65:56:b9:ad:88:f9:81:2b:37:74:2f"
          )
          
          # Use the key information
          UI.message("Key type: #{key_info["type"]}, Public key: #{key_info["public_key"]}")'
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