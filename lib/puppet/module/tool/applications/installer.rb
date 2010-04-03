require 'open-uri'
require 'pathname'
require 'tmpdir'

module Puppet::Module::Tool

  module Applications

    class Installer < Application

      def initialize(name, options = {})
        if File.exist?(name)
          @source = :filesystem
          @filename = File.expand_path(name)
          parse_filename!
        else
          @source = :repository
          @username, @module_name = name.split('/')
          @version_requirement = options[:version]
        end
        super(options)
      end

      def force?
        options[:force]
      end

      def run
        case @source
        when :repository
          if match['file']
            cache_path = Puppet::Module::Tool.config.repository.retrieve(match['file'])
            Unpacker.run(cache_path, Dir.pwd, options)
          else
            abort "Malformed response from module repository."
          end
        when :filesystem
          repository = Repository.new('file:///')
          cache_path = repository.retrieve(@filename)
          Unpacker.run(cache_path, Dir.pwd, options)
        else
          abort "Could not determine installation source"
        end
      end

      private

      def match
        unless @match
          url = Puppet::Modules::Tool.repository.uri + "/users/#{@username}/modules/#{@module_name}/releases/find.json"
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
