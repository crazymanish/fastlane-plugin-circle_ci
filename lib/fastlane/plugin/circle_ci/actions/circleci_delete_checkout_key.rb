require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeleteCheckoutKeyAction < Action
      def self.run(params)
        UI.message("Deleting CircleCI project checkout key via API v2...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        fingerprint = params[:fingerprint]
        
        # Make API request
        result = Helper::CircleCiHelper.delete_v2("project/#{project_slug}/checkout-key/#{fingerprint}", api_token)
        
        UI.success("Successfully deleted checkout key with fingerprint #{fingerprint} from project #{project_slug}")
        
        return result
      end

      def self.description
        "Deletes a checkout key from a CircleCI project using API v2"
      end

      def self.details
        "This action deletes a specific checkout key from a CircleCI project using the CircleCI API v2. You need to provide the fingerprint of the key you want to delete."
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
                                       description: "The fingerprint of the checkout key to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash with a 'message' key indicating success or failure."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_checkout_key(
            project_slug: "gh/MyOrg/my-project",
            fingerprint: "c9:0b:1c:4f:d5:65:56:b9:ad:88:f9:81:2b:37:74:2f"
          )',
          '# Get keys first, then delete one
          keys = circleci_get_checkout_keys(
            project_slug: "gh/MyOrg/my-project"
          )
          
          # Delete the first key
          if keys["items"].any?
            circleci_delete_checkout_key(
              project_slug: "gh/MyOrg/my-project",
              fingerprint: keys["items"].first["fingerprint"]
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