module Puppet::Module::Tool
  module Applications

    class Unreleaser < Application
      # TODO Review whether the 'unrelease' feature should be fixed or deleted.
=begin
      def initialize(address, options = {})
        @address = address
        @username, @module_name = address.split('/')
        validate!
        super(options)
      end

      def version
        options[:version]
      end

      def run
        if confirms?("Unrelease #{@address} #{version}?")
          request = Net::HTTP::Delete.new("/users/#{@username}/modules/#{@module_name}/releases/#{version}")
          response = repository.contact(request, :authenticate => true)
          discuss response, "Unreleased #{@address} #{version}", "Could not unrelease #{@address} #{version}"
        end
      end

      private
      
      def validate!
        unless @username && @module_name
          abort "Username and Module name not provided"
        end
        begin
          Versionomy.parse(version)
        rescue
          abort "Invalid version format: #{version}"
        end
      end
=end
    end
    
  end
end
