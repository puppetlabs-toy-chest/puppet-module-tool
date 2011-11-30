require 'open-uri'
require 'pathname'
require 'tmpdir'

module Puppet::Module::Tool

  module Applications

    class Installer < Application

      def initialize(name, options = {})
        if File.exist?(name)
          if File.directory?(name)
            # TODO Unify this handling with that of Unpacker#check_clobber!
            abort "Module already installed: #{name}"
          end
          @source = :filesystem
          @filename = File.expand_path(name)
          parse_filename!
        else
          @source = :repository
          begin
            @username, @module_name = Puppet::Module::Tool::username_and_modname_from(name)
          rescue ArgumentError
            abort "Could not install module with invalid name: #{name}"
          end
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
            begin
              cache_path = repository.retrieve(match['file'])
            rescue OpenURI::HTTPError => e
              abort "Could not install module: #{e.message}"
            end
            Unpacker.run(cache_path, Dir.pwd, options)
          else
            abort "Malformed response from module repository."
          end
        when :filesystem
          repository = Repository.new('file:///')
          uri = URI.parse("file://#{File.expand_path(@filename)}")
          cache_path = repository.retrieve(uri)
          Unpacker.run(cache_path, Dir.pwd, options)
        else
          abort "Could not determine installation source"
        end
      end

      private

      def match
        return @match ||= begin
          url = repository.uri + "/users/#{@username}/modules/#{@module_name}/releases/find.json"
          if @version_requirement
            url.query = "version=#{URI.escape(@version_requirement)}"
          end
          begin
            raw_result = read_match(url)
          rescue => e
            abort "Could not find a release for this module (#{e.message})"
          end
          @match = PSON.parse(raw_result)
        end
      end

      def read_match(url)
        return url.read
      end

    end

  end
end
