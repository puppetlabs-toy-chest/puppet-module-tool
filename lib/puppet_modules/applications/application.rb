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

      def metadata(require_modulefile = false)
        unless @metadata
          unless @path
            abort "Could not determine module path"
          end
          @metadata = Metadata.new
          contents = ContentsDescription.new(@path)
          contents.annotate(@metadata)
          modulefile_path = File.join(@path, 'Modulefile')
          if File.file?(modulefile_path)
            Modulefile.evaluate(@metadata, modulefile_path)
          elsif require_modulefile
            abort "No Modulefile found."
          end
        end
        @metadata
      end

      def load_modulefile!
        @metadata = nil
        metadata(true)
      end
      
    end

  end
end
