require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CHECKOUT_KEYS = :CIRCLECI_CHECKOUT_KEYS
    end

    class CircleciGetCheckoutKeysAction < Action
      def self.run(params)
        UI.message("Getting CircleCI project checkout keys via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/checkout-key", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CHECKOUT_KEYS] = result
        
        UI.success("Successfully retrieved checkout keys for project #{project_slug}")
        
        return result
      end

      def self.description
        "Gets all checkout keys for a CircleCI project using API v2"
      end

      def self.details
        "This action retrieves all checkout keys for a specific CircleCI project using the CircleCI API v2. Checkout keys are used to check out code from your version control system."
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
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CHECKOUT_KEYS', 'A hash containing checkout keys information']
        ]
      end

      def self.return_value
        "Returns a hash containing checkout keys information including type, fingerprint, and preferred status."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_checkout_keys(
            project_slug: "gh/MyOrg/my-project"
          )',
          'keys = circleci_get_checkout_keys(
            project_slug: "gh/MyOrg/my-project"
          )
          
          # Use the checkout keys
          keys["items"].each do |key|
            UI.message("Found key: #{key["type"]} with fingerprint #{key["fingerprint"]}")
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