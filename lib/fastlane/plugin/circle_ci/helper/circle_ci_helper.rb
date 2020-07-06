require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CircleCiHelper
      def self.execute(curl_command)
        response = Fastlane::Actions::sh("#{curl_command}", log: false)

        require 'json'
        JSON.parse(response) || {}
      end
    end
  end
end
