require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_CONTEXT_ENV_VARS = :CIRCLECI_CONTEXT_ENV_VARS
    end

    class CircleciGetContextEnvVarsAction < Action
      def self.run(params)
        UI.message("Getting CircleCI context environment variables via API v2...")
        
        api_token = params[:api_token]
        context_id = params[:context_id]
        
        # Make API request
        result = Helper::CircleCiHelper.get_v2("context/#{context_id}/environment-variable", api_token)
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_CONTEXT_ENV_VARS] = result["items"]
        
        UI.success("Successfully retrieved #{result["items"].count} environment variables for context #{context_id}")
        
        return result["items"]
      end

      def self.description
        "Gets environment variables for a CircleCI context using API v2"
      end

      def self.details
        "This action retrieves all environment variables for a specific CircleCI context using the CircleCI API v2. For security reasons, values are not returned, only variable names."
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
          FastlaneCore::ConfigItem.new(key: :context_id,
                                       env_name: "CIRCLE_CI_CONTEXT_ID",
                                       description: "The ID of the context to get environment variables for",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CIRCLECI_CONTEXT_ENV_VARS', 'An array of environment variable names for the context']
        ]
      end

      def self.return_value
        "Returns an array of environment variable data. For security reasons, only variable names are provided, not values."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_get_context_env_vars(
            context_id: "context-uuid"
          )',
          '# First get all contexts, then find a specific one and its environment variables
          contexts = circleci_list_contexts(
            owner_slug: "github/myorg"
          )
          
          # Find the production context
          prod_context = contexts.find { |c| c["name"] == "production" }
          
          if prod_context
            # Get all environment variables in the production context
            env_vars = circleci_get_context_env_vars(
              context_id: prod_context["id"]
            )
            
            # Check if a specific variable exists
            if env_vars.any? { |var| var["variable"] == "API_KEY" }
              UI.success("API_KEY is set in the production context")
            else
              UI.important("API_KEY is missing from the production context")
              
              # Add the missing variable
              circleci_add_context_env_var(
                context_id: prod_context["id"],
                env_var_name: "API_KEY",
                env_var_value: "secret-api-key-value"
              )
            end
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