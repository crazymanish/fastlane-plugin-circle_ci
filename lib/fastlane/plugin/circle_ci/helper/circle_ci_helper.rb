require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CircleCiHelper
      # class methods that you define here become available in your action
      # as `Helper::CircleCiHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the circle_ci plugin helper!")
      end
    end
  end
end
