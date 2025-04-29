require 'fastlane/action'
require 'fileutils'
require_relative '../helper/circle_ci_helper'

module Fastlane
  module Actions
    module SharedValues
      CIRCLECI_DOWNLOADED_ARTIFACTS = :CIRCLECI_DOWNLOADED_ARTIFACTS
    end

    class CircleciDownloadWorkflowArtifactsAction < Action
      def self.run(params)
        UI.message("Downloading artifacts from CircleCI workflow...")
        
        api_token = params[:api_token]
        project_slug = params[:project_slug]
        branch = params[:branch]
        workflow_name = params[:workflow_name]
        destination_dir = params[:destination_dir]
        
        # Create destination directory if it doesn't exist
        FileUtils.mkdir_p(destination_dir)
        
        UI.important("Looking for the latest pipeline on #{branch} branch...")
        
        # Get recent pipelines for the project
        pipelines = Helper::CircleCiHelper.get_v2("project/#{project_slug}/pipeline", api_token)
        
        # Find the latest pipeline for the specified branch
        target_pipeline = nil
        target_workflow = nil
        
        # Continue searching for pipelines until we find one with the target workflow
        pipeline_page = 1
        max_pages_to_search = 10 # Limit how far back we search to avoid excessive API calls
        
        while target_workflow.nil? && pipeline_page <= max_pages_to_search
          if pipeline_page > 1
            UI.important("Workflow '#{workflow_name}' not found in recent pipelines. Checking older pipelines (page #{pipeline_page})...")
            # Get older pipelines with pagination
            pipelines = Helper::CircleCiHelper.get_v2("project/#{project_slug}/pipeline", api_token, { page: pipeline_page })
          end
          
          # Check each pipeline on this page for the target branch and workflow
          pipelines["items"].each do |pipeline|
            next unless pipeline["vcs"] && pipeline["vcs"]["branch"] == branch
            
            UI.message("Checking pipeline ##{pipeline['number']} on #{branch} branch...")
            
            # Get the workflows for this pipeline
            workflows = Helper::CircleCiHelper.get_v2("pipeline/#{pipeline["id"]}/workflow", api_token)
            
            # Find the target workflow
            workflow = workflows["items"].find { |w| w["name"] == workflow_name }
            
            if workflow
              target_pipeline = pipeline
              target_workflow = workflow
              UI.success("Found #{workflow_name} workflow in pipeline ##{pipeline["number"]}")
              break
            end
          end
          
          pipeline_page += 1
        end
        
        if target_pipeline.nil?
          UI.user_error!("No pipeline found for #{branch} branch")
        end
        
        if target_workflow.nil?
          UI.user_error!("No '#{workflow_name}' workflow found in any recent pipelines for #{branch} branch")
        else
          UI.success("Using #{workflow_name} workflow: #{target_workflow["id"]} from pipeline ##{target_pipeline["number"]}")
        end
        
        # Get the jobs for the workflow
        jobs_result = Helper::CircleCiHelper.get_v2("workflow/#{target_workflow["id"]}/job", api_token)
        jobs = jobs_result["items"]
        
        UI.important("Found #{jobs.count} jobs in the #{workflow_name} workflow")
        
        # Download artifacts for each job
        downloaded_artifacts = []
        total_artifacts = 0
        
        jobs.each do |job|
          UI.message("Getting artifacts for job: #{job["name"]}")
          
          # Skip jobs with no number (haven't run yet)
          next unless job["job_number"]
          
          # Get artifacts for this job
          artifacts_result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/#{job["job_number"]}/artifacts", api_token)
          artifacts = artifacts_result["items"]
          
          if artifacts.empty?
            UI.message("No artifacts found for job: #{job["name"]}")
            next
          end
          
          UI.success("Found #{artifacts.count} artifacts for job: #{job["name"]}")
          
          # Download each artifact
          job_artifacts = []
          
          artifacts.each do |artifact|
            job_dir = File.join(destination_dir, job["name"])
            FileUtils.mkdir_p(job_dir)
            
            artifact_filename = File.basename(artifact["path"])
            download_path = File.join(job_dir, artifact_filename)
            
            UI.message("Downloading artifact: #{artifact["path"]} to #{download_path}")
            
            # Configure Faraday
            conn = Faraday.new do |f|
              f.headers['Circle-Token'] = api_token if api_token
              f.response :follow_redirects
              f.adapter Faraday.default_adapter
            end
            
            # Download the file
            begin
              response = conn.get(artifact["url"])
              
              if response.status >= 200 && response.status < 300
                # Write the response body to the destination file
                File.binwrite(download_path, response.body)
                job_artifacts << {
                  job_name: job["name"],
                  artifact_path: artifact["path"],
                  url: artifact["url"],
                  download_path: download_path
                }
                total_artifacts += 1
                UI.success("Successfully downloaded artifact to #{download_path}")
              else
                UI.error("Failed to download artifact: HTTP #{response.status}")
              end
            rescue => e
              UI.error("Error downloading artifact: #{e.message}")
            end
          end
          
          downloaded_artifacts << {
            job_name: job["name"],
            job_number: job["job_number"],
            artifacts: job_artifacts
          } unless job_artifacts.empty?
        end
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_DOWNLOADED_ARTIFACTS] = downloaded_artifacts
        
        result = {
          workflow_id: target_workflow["id"],
          workflow_name: workflow_name,
          pipeline_number: target_pipeline["number"],
          pipeline_id: target_pipeline["id"],
          branch: branch,
          total_artifacts: total_artifacts,
          downloaded_artifacts: downloaded_artifacts,
          destination_dir: destination_dir
        }
        
        UI.success("Downloaded #{total_artifacts} artifacts from the '#{workflow_name}' workflow on #{branch} branch to #{destination_dir}")
        
        return result
      end

      def self.description
        "Downloads artifacts from a specific CircleCI workflow"
      end

      def self.details
        "This action downloads all artifacts from a specific CircleCI workflow. By default, it targets the most recent 'test' workflow from the master branch, but you can customize all parameters. Artifacts are downloaded to the specified directory, organized by job name."
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
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "CIRCLE_CI_BRANCH",
                                       description: "The name of the branch to search for workflows",
                                       is_string: true,
                                       default_value: "master",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :workflow_name,
                                       env_name: "CIRCLE_CI_WORKFLOW_NAME",
                                       description: "The name of the workflow to download artifacts from",
                                       is_string: true,
                                       default_value: "test",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :destination_dir,
                                       env_name: "CIRCLE_CI_ARTIFACT_DESTINATION_DIR",
                                       description: "Directory where artifacts should be saved",
                                       is_string: true,
                                       default_value: "./artifacts",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['CIRCLECI_DOWNLOADED_ARTIFACTS', 'An array of downloaded artifacts information grouped by job']
        ]
      end

      def self.return_value
        "Returns a hash containing information about the download process, including workflow ID, pipeline details, branch, and downloaded artifacts."
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo"
          )',
          'artifacts_info = circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo",
            branch: "feature/my-branch",
            workflow_name: "integration",
            destination_dir: "./my-artifacts"
          )
          
          # Print summary of downloaded artifacts
          UI.message("Downloaded #{artifacts_info[:total_artifacts]} artifacts from #{artifacts_info[:workflow_name]} workflow")
          
          # Process downloaded artifacts
          artifacts_info[:downloaded_artifacts].each do |job_artifacts|
            job_name = job_artifacts[:job_name]
            job_artifacts[:artifacts].each do |artifact|
              path = artifact[:download_path]
              # Process artifact files as needed
              puts "Processing #{path} from job #{job_name}"
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