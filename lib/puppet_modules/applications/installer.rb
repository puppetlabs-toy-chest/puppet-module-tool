require 'open-uri'
require 'pathname'
require 'tmpdir'

module PuppetModules

  module Applications

    class Installer < Application

      def initialize(name, version_requirement = nil, force = false)
        @username, @module_name = name.split('/')
        @version_requirement = version_requirement
        @force = force
      end

      def run
        if match['file']
          cache_path = PuppetModules.repository.retrieve(match['file'])
          Unpacker.run(cache_path, Dir.pwd, @force)
        else
          abort "Malformed response from module repository."
        end
      end

      private

      def match
        unless @match
          url = PuppetModules.repository.uri + "/users/#{@username}/modules/#{@module_name}/releases/find.json"
          if @version_requirement
            url.query = "version=#{URI.escape(@version_requirement)}"
          end
          begin
            raw_result = url.read
          rescue => e
            abort "Could not request version match (#{e.message})"
          end
          @match = PSON.parse(raw_result)
        end
        @match
      end

    end
    
  end
end
