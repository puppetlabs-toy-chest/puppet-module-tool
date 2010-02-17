require 'puppet'
require 'open-uri'

module Puppet
  module Applications

    class ModuleInstaller

      def initialize(repository, name)
        @repository = repository
        @name = name
      end

      def run
        puts "git clone #{source} #{simple_name}"
        system "git", "clone", source.to_s, simple_name
      end

      private

      def simple_name
        @name.split('/').last
      end

      def source
        @source ||=
          begin
            uri = @repository + "/#{@name}.json"
            data = PSON.parse(uri.read)
            URI.parse(data['source'])
          end
      end

    end
    
  end
end
