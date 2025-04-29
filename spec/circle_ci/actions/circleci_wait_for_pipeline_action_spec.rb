require 'spec_helper'

describe Fastlane::Actions::CircleciWaitForPipelineAction do
  describe '#run' do
    it 'polls the CircleCI API until pipeline completes' do
      api_token = 'fake_token'
      pipeline_id = '12345-67890-abcdef'
      params = {
        api_token: api_token,
        pipeline_id: pipeline_id,
        timeout: 60,        # Shorter timeout for test
        poll_interval: 0.1  # Shorter interval for test
      }

      # Mock API responses for polling
      pending_response = { 'state' => 'pending' }
      success_response = { 'state' => 'success' }
      
      # Expect to poll the API twice - first returning pending, then success
      expect(Fastlane::Actions::Helper::CircleCiHelper).to receive(:get_v2)
        .with("pipeline/#{pipeline_id}", api_token)
        .and_return(pending_response, success_response)
      
      # Mock sleep to avoid actual waiting in tests
      expect_any_instance_of(Object).to receive(:sleep).with(0.1).once
      
      # Run the action
      result = Fastlane::Actions::CircleciWaitForPipelineAction.run(params)
      
      # Verify the result
      expect(result[:success]).to be true
      expect(result[:status]).to eq('success')
      expect(result[:pipeline_id]).to eq(pipeline_id)
      expect(result[:waited]).to be_a(Float)
      
      # Verify the lane context is set
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CIRCLECI_WAIT_RESULT]).to eq(result)
    end
    
    it 'times out if pipeline does not complete' do
      api_token = 'fake_token'
      pipeline_id = '12345-67890-abcdef'
      params = {
        api_token: api_token,
        pipeline_id: pipeline_id,
        timeout: 0.5,       # Very short timeout to trigger timeout in test
        poll_interval: 0.2  # Short interval for test
      }

      # Mock API response to always return pending
      pending_response = { 'state' => 'pending' }
      
      # Expect to poll the API multiple times, always returning pending
      expect(Fastlane::Actions::Helper::CircleCiHelper).to receive(:get_v2)
        .with("pipeline/#{pipeline_id}", api_token)
        .and_return(pending_response)
        .at_least(:once)
      
      # Mock sleep to avoid actual waiting in tests
      expect_any_instance_of(Object).to receive(:sleep).with(0.2).at_least(:once)
      
      # Run the action
      result = Fastlane::Actions::CircleciWaitForPipelineAction.run(params)
      
      # Verify the result indicates timeout
      expect(result[:success]).to be false
      expect(result[:status]).to eq('timeout')
      expect(result[:pipeline_id]).to eq(pipeline_id)
      expect(result[:waited]).to be_a(Float)
    end
  end

  describe '#authors' do
    it 'includes the expected authors' do
      expect(Fastlane::Actions::CircleciWaitForPipelineAction.authors).to eq(['crazymanish', 'copilot'])
    end
  end
end