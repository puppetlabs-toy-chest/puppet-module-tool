require 'uri'

module Puppet::Module::Tool
  module Utils
    module URI

      def normalize(url)
        url.is_a?(::URI) ? url : ::URI.parse(url)
      end

    end
  end
end
