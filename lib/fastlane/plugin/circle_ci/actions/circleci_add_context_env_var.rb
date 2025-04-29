require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciAddContextEnvVarAction < Action
      def self.run(params)
        UI.message("Adding environment variable to CircleCI context via API v2...")
        
        api_token = params[:api_token]
        context_id = params[:context_id]
        env_var_name = params[:env_var_name]
        env_var_value = params[:env_var_value]
        
        # Prepare request body
        body = {
          variable: env_var_name,
          value: env_var_value
        }
        
        # Make API request
        result = Helper::CircleCiHelper.put_v2("context/#{context_id}/environment-variable/#{env_var_name}", api_token, body)
        
        UI.success("Successfully added environment variable '#{env_var_name}' to context #{context_id}")
        
        return result
      end

      def self.description
        "Adds an environment variable to a CircleCI context using API v2"
      end

      def self.details
        "This action adds or updates an environment variable in a specific CircleCI context using the CircleCI API v2. Environment variables in contexts are used to securely share configuration across projects."
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
                                       description: "The ID of the context to add the environment variable to",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :env_var_name,
                                       env_name: "CIRCLE_CI_ENV_VAR_NAME",
                                       description: "The name of the environment variable",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :env_var_value,
                                       env_name: "CIRCLE_CI_ENV_VAR_VALUE",
                                       description: "The value of the environment variable",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns a hash containing the created environment variable information (without the actual value for security)."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_add_context_env_var(
            context_id: "context-uuid",
            env_var_name: "API_KEY",
            env_var_value: "secret-value"
          )',
          '# First find the context, then add a variable to it
          contexts = circleci_list_contexts(
            owner_slug: "github/myorg"
          )
          
          # Find the staging context
          staging_context = contexts.find { |c| c["name"] == "staging" }
          
          if staging_context
            # Add or update environment variables for staging
            circleci_add_context_env_var(
              context_id: staging_context["id"],
              env_var_name: "DEPLOY_URL",
              env_var_value: "https://staging.example.com"
            )
            
            circleci_add_context_env_var(
              context_id: staging_context["id"],
              env_var_name: "STAGE",
              env_var_value: "staging"
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