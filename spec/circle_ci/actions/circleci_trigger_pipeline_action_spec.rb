require 'spec_helper'

describe Fastlane::Actions::CircleciTriggerPipelineAction do
  describe '#run' do
    it 'makes a POST request to the CircleCI API' do
      api_token = 'fake_token'
      project_slug = 'github/org/repo'
      branch = 'main'
      params = {
        api_token: api_token,
        project_slug: project_slug,
        branch: branch,
        parameters: { 'test_param' => 'test_value' }
      }

      # Mock the CircleCI API response
      expected_response = {
        'id' => '12345-67890-abcdef',
        'number' => 123,
        'state' => 'pending'
      }

      # Set up expectations
      expect(Fastlane::Actions::Helper::CircleCiHelper).to receive(:post_v2)
        .with('project/github/org/repo/pipeline', api_token, { branch: branch, parameters: { 'test_param' => 'test_value' } })
        .and_return(expected_response)

      # Run the action
      result = Fastlane::Actions::CircleciTriggerPipelineAction.run(params)

      # Verify the result
      expect(result).to eq(expected_response)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CIRCLECI_PIPELINE_ID]).to eq('12345-67890-abcdef')
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CIRCLECI_PIPELINE_NUMBER]).to eq(123)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CIRCLECI_PIPELINE_URL]).to include('app.circleci.com/pipelines/github/org/repo/123')
    end
  end

  describe '#available_options' do
    it 'includes the expected options' do
      options = Fastlane::Actions::CircleciTriggerPipelineAction.available_options

      # Verify each required option exists
      expect(options.find { |o| o.key == :api_token }).not_to be_nil
      expect(options.find { |o| o.key == :project_slug }).not_to be_nil
      expect(options.find { |o| o.key == :branch }).not_to be_nil
      expect(options.find { |o| o.key == :parameters }).not_to be_nil
    end
  end

  describe '#authors' do
    it 'includes the expected authors' do
      expect(Fastlane::Actions::CircleciTriggerPipelineAction.authors).to eq(['crazymanish', 'copilot'])
    end
  end

  describe '#is_supported?' do
    it 'returns true for all platforms' do
      expect(Fastlane::Actions::CircleciTriggerPipelineAction.is_supported?(:ios)).to be true
      expect(Fastlane::Actions::CircleciTriggerPipelineAction.is_supported?(:android)).to be true
    end
  end
end