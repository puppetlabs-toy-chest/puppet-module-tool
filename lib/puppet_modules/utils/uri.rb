require 'uri'

module PuppetModules
  module Utils
    module URI

      def normalize(url)
        url.is_a?(::URI) ? url : ::URI.parse(url)
      end

    end
  end
end
