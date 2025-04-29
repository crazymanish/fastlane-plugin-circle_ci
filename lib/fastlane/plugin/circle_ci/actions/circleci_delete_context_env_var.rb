require 'fastlane/action'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    class CircleciDeleteContextEnvVarAction < Action
      def self.run(params)
        UI.message("Deleting environment variable from CircleCI context via API v2...")
        
        api_token = params[:api_token]
        context_id = params[:context_id]
        env_var_name = params[:env_var_name]
        
        # Make API request
        begin
          Helper::CircleCiHelper.delete_v2("context/#{context_id}/environment-variable/#{env_var_name}", api_token)
          UI.success("Successfully deleted environment variable '#{env_var_name}' from context #{context_id}")
          return true
        rescue => e
          UI.error("Failed to delete environment variable: #{e.message}")
          return false
        end
      end

      def self.description
        "Deletes an environment variable from a CircleCI context using API v2"
      end

      def self.details
        "This action deletes an environment variable from a specific CircleCI context using the CircleCI API v2."
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
                                       description: "The ID of the context to delete the environment variable from",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :env_var_name,
                                       env_name: "CIRCLE_CI_ENV_VAR_NAME",
                                       description: "The name of the environment variable to delete",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "Returns true if the deletion was successful, false otherwise."
      end

      def self.authors
        ["crazymanish", "copilot"]
      end

      def self.example_code
        [
          'circleci_delete_context_env_var(
            context_id: "context-uuid",
            env_var_name: "DEPRECATED_API_KEY"
          )',
          '# Clean up old environment variables from a context
          contexts = circleci_list_contexts(
            owner_slug: "github/myorg"
          )
          
          # Find the development context
          dev_context = contexts.find { |c| c["name"] == "development" }
          
          if dev_context
            # Get current environment variables
            env_vars = circleci_get_context_env_vars(
              context_id: dev_context["id"]
            )
            
            # Remove deprecated variables
            deprecated_vars = ["OLD_API_URL", "LEGACY_TOKEN", "UNUSED_VAR"]
            
            deprecated_vars.each do |var_name|
              if env_vars.any? { |var| var["variable"] == var_name }
                circleci_delete_context_env_var(
                  context_id: dev_context["id"],
                  env_var_name: var_name
                )
                UI.important("Removed deprecated variable: #{var_name}")
              end
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