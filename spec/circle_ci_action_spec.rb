describe Fastlane::Actions::CircleCiAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The circle_ci plugin is working!")

      Fastlane::Actions::CircleCiAction.run(nil)
    end
  end
end
