require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CONTEXTS = :CIRCLECI_CONTEXTS
    end

    class CircleciListContextsAction < Action
      def self.run(params)
        UI.message("Listing CircleCI contexts via API v2...")
        
        api_token = params[:api_token]
        owner_id = params[:owner_id]
        owner_type = params[:owner_type]
        owner_slug = params[:owner_slug]
        
        query_params = {}
        
        # Determine if we're using owner-id or owner-slug
        if owner_id && owner_type
          query_params["owner-id"] = owner_id
          query_params["owner-type"] = owner_type
          UI.verbose("Using owner-id: #{owner_id} and owner-type: #{owner_type}")
        elsif owner_slug
          query_params["owner-slug"] = owner_slug
          UI.verbose("Using owner-slug: #{owner_slug}")
        else
          UI.user_error!("Either owner_id and owner_type, or owner_slug must be provided")
        end
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("context", api_token, query_params)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CONTEXTS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} contexts")
        
        return result["items"]
      end

      def self.description
        "Lists CircleCI contexts using API v2"
      end

      def self.details
        "This action lists all contexts for an organization or account using the CircleCI API v2. Contexts allow you to share environment variables across multiple projects."
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
          FastlaneCore::ConfigItem.new(key: :owner_id,
                                       env_name: "CIRCLE_CI_CONTEXT_OWNER_ID",
                                       description: "The ID of the context owner (organization or account)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :owner_type,
                                       env_name: "CIRCLE_CI_CONTEXT_OWNER_TYPE",
                                       description: "The type of the context owner (organization or account)",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Owner type must be either 'organization' or 'account'") unless ['organization', 'account'].include?(value)
                                       end,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :owner_slug,
                                       env_name: "CIRCLE_CI_CONTEXT_OWNER_SLUG",
                                       description: "The slug of the context owner (e.g., github/myorg)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CONTEXTS', 'An array of context data']
        ]
      end

      def self.return_value
        "Returns an array of context data including IDs, names, and creation timestamps."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_list_contexts(
            owner_slug: "github/myorg"
          )',
          'circleci_list_contexts(
            owner_id: "organization-uuid",
            owner_type: "organization"
          )',
          'contexts = circleci_list_contexts(
            owner_slug: "github/myorg"
          )
          
          # Find a specific context
          staging_context = contexts.find { |c| c["name"] == "staging" }
          
          if staging_context
            # Get environment variables for this context
            env_vars = circleci_get_context_env_vars(
              context_id: staging_context["id"]
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