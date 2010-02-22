require 'puppet'
require 'net/http'

module PuppetModules
  module Applications

    class Application
      extend Utils::WhinyRequire
      include Utils::Interrogation

      def self.requires(*requires)
        whiny_require(*requires)
      end

      def self.run(*args)
        new(*args).run
      end

      def repository
        PuppetModules.repository
      end

      def run
        raise NotImplementedError, "Should be implemented in child classes."
      end

      def discuss(response, success, failure)
        case response
        when Net::HTTPOK
          say success
        else
          errors = PSON.parse(response.body)['error'] rescue "HTTP #{response.code}, #{response.body}"
          say "#{failure} (#{errors})"
        end
      end
      
    end

  end
end
