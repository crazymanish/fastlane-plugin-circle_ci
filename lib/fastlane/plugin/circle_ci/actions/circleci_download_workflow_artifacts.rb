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
        
        # Extract parameters
        api_token, project_slug, branch, workflow_name, job_name, destination_dir, file_extensions = extract_params(params)
        
        # Create destination directory if it doesn't exist
        FileUtils.mkdir_p(destination_dir)
        
        # Find the target pipeline and workflow
        target_pipeline, target_workflow = find_target_pipeline_and_workflow(api_token, project_slug, branch, workflow_name)
        
        # Get the jobs for the workflow and download artifacts
        downloaded_artifacts, total_artifacts = download_job_artifacts(
          api_token, 
          project_slug, 
          target_workflow, 
          workflow_name, 
          destination_dir,
          file_extensions,
          job_name
        )
        
        # Store values in lane context
        Actions.lane_context[SharedValues::CIRCLECI_DOWNLOADED_ARTIFACTS] = downloaded_artifacts
        
        # Prepare and return the result
        result = prepare_result(
          target_workflow,
          workflow_name,
          target_pipeline,
          branch,
          total_artifacts,
          downloaded_artifacts,
          destination_dir
        )
        
        UI.success("Downloaded #{total_artifacts} artifacts from the '#{workflow_name}' workflow on #{branch} branch to #{destination_dir}")
        
        return result
      end

      def self.extract_params(params)
        [
          params[:api_token],
          params[:project_slug],
          params[:branch],
          params[:workflow_name],
          params[:job_name],
          params[:destination_dir],
          params[:file_extensions]
        ]
      end

      def self.find_target_pipeline_and_workflow(api_token, project_slug, branch, workflow_name)
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
            
            # Find the target workflow with status "success"
            workflow = workflows["items"].find { |w| w["name"] == workflow_name && w["status"] == "success" }
            
            if workflow
              target_pipeline = pipeline
              target_workflow = workflow
              UI.success("Found #{workflow_name} workflow with status 'success' in pipeline ##{pipeline["number"]}")
              break
            end
          end
          
          pipeline_page += 1
        end
        
        if target_pipeline.nil?
          UI.user_error!("No pipeline found for #{branch} branch")
        end
        
        if target_workflow.nil?
          UI.user_error!("No successful '#{workflow_name}' workflow found in any recent pipelines for #{branch} branch")
        else
          UI.success("Using #{workflow_name} workflow: #{target_workflow["id"]} from pipeline ##{target_pipeline["number"]}")
        end
        
        return [target_pipeline, target_workflow]
      end

      def self.download_job_artifacts(api_token, project_slug, target_workflow, workflow_name, destination_dir, file_extensions = nil, job_name = nil)
        # Get the jobs for the workflow
        jobs_result = Helper::CircleCiHelper.get_v2("workflow/#{target_workflow["id"]}/job", api_token)
        jobs = jobs_result["items"]
        
        UI.important("Found #{jobs.count} jobs in the #{workflow_name} workflow")
        
        # Filter jobs by name if specified
        if job_name
          jobs = jobs.select { |job| job["name"] == job_name }
          if jobs.empty?
            UI.user_error!("No job found with name '#{job_name}' in the #{workflow_name} workflow")
          end
          UI.important("Filtering to only download artifacts from job: #{job_name}")
        end
        
        # Download artifacts for each job
        downloaded_artifacts = []
        total_artifacts = 0
        
        jobs.each do |job|
          job_artifacts = download_artifacts_for_job(api_token, project_slug, job, destination_dir, file_extensions)
          
          if !job_artifacts.empty?
            downloaded_artifacts << {
              job_name: job["name"],
              job_number: job["job_number"],
              artifacts: job_artifacts
            }
            total_artifacts += job_artifacts.count
          end
        end
        
        return [downloaded_artifacts, total_artifacts]
      end

      def self.download_artifacts_for_job(api_token, project_slug, job, destination_dir, file_extensions = nil)
        UI.message("Getting artifacts for job: #{job["name"]}")
        
        # Skip jobs with no number (haven't run yet)
        return [] unless job["job_number"]
        
        # Get artifacts for this job
        artifacts_result = Helper::CircleCiHelper.get_v2("project/#{project_slug}/#{job["job_number"]}/artifacts", api_token)
        artifacts = artifacts_result["items"]
        
        if artifacts.empty?
          UI.message("No artifacts found for job: #{job["name"]}")
          return []
        end
        
        # Filter artifacts by extension if specified
        if file_extensions
          extensions = file_extensions.is_a?(Array) ? file_extensions : [file_extensions.to_s]
          filtered_artifacts = filter_artifacts_by_extension(artifacts, extensions)
          
          if filtered_artifacts.empty?
            UI.message("No artifacts with extensions #{extensions.join(', ')} found for job: #{job["name"]}")
            return []
          end
          
          UI.success("Found #{filtered_artifacts.count} artifacts with extensions #{extensions.join(', ')} for job: #{job["name"]}")
          artifacts = filtered_artifacts
        else
          UI.success("Found #{artifacts.count} artifacts for job: #{job["name"]}")
        end
        
        # Download each artifact
        download_artifacts(api_token, job["name"], artifacts, destination_dir)
      end
      
      def self.filter_artifacts_by_extension(artifacts, extensions)
        artifacts.select do |artifact|
          # Get the file extension from the path
          ext = File.extname(artifact["path"]).delete('.')
          extensions.include?(ext.downcase)
        end
      end
      
      def self.download_artifacts(api_token, job_name, artifacts, destination_dir)
        job_artifacts = []
        
        artifacts.each do |artifact|
          download_path = prepare_download_path(destination_dir, job_name, artifact)
          
          if download_artifact(api_token, artifact, download_path)
            job_artifacts << {
              job_name: job_name,
              artifact_path: artifact["path"],
              url: artifact["url"],
              download_path: download_path
            }
          end
        end
        
        return job_artifacts
      end

      def self.prepare_download_path(destination_dir, job_name, artifact)
        job_dir = File.join(destination_dir, job_name)
        FileUtils.mkdir_p(job_dir)
        
        artifact_filename = File.basename(artifact["path"])
        File.join(job_dir, artifact_filename)
      end

      def self.download_artifact(api_token, artifact, download_path)
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
            File.open(download_path, "wb") do |file|
              file.write(response.body)
            end
            UI.success("Successfully downloaded artifact to #{download_path}")
            return true
          else
            UI.error("Failed to download artifact: HTTP #{response.status}")
            return false
          end
        rescue => e
          UI.error("Error downloading artifact: #{e.message}")
          return false
        end
      end

      def self.prepare_result(target_workflow, workflow_name, target_pipeline, branch, total_artifacts, downloaded_artifacts, destination_dir)
        {
          workflow_id: target_workflow["id"],
          workflow_name: workflow_name,
          pipeline_number: target_pipeline["number"],
          pipeline_id: target_pipeline["id"],
          branch: branch,
          total_artifacts: total_artifacts,
          downloaded_artifacts: downloaded_artifacts,
          destination_dir: destination_dir
        }
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
          FastlaneCore::ConfigItem.new(key: :job_name,
                                       env_name: "CIRCLE_CI_JOB_NAME",
                                       description: "The name of a specific job to download artifacts from (if not provided, artifacts from all jobs will be downloaded)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :destination_dir,
                                       env_name: "CIRCLE_CI_ARTIFACT_DESTINATION_DIR",
                                       description: "Directory where artifacts should be saved",
                                       is_string: true,
                                       default_value: "./artifacts",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :file_extensions,
                                       env_name: "CIRCLE_CI_ARTIFACT_FILE_EXTENSIONS",
                                       description: "File extensions to download (e.g. 'json' or ['json', 'xml']). If provided, only files with these extensions will be downloaded",
                                       is_string: false,
                                       default_value: "json",
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
          '# Download only JSON files (default)
          circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo"
          )',
          '# Download only XML files
          circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo",
            file_extensions: "xml"
          )',
          '# Download both JSON and XML files
          circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo",
            file_extensions: ["json", "xml"]
          )',
          '# Download artifacts from a specific job only
          circleci_download_workflow_artifacts(
            project_slug: "github/myorg/myrepo",
            job_name: "build"
          )',
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