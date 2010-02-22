module PuppetModules
  module Applications

    class Unreleaser < Application

      def initialize(address, version)
        @address = address
        @username, @module_name = address.split('/')
        @version = version
        validate!
      end

      def run
        if confirms?("Unrelease #{@address} #{@version}?")
          request = Net::HTTP::Delete.new("/users/#{@username}/modules/#{@module_name}/releases/#{@version}")
          response = repository.contact(request, :authenticate => true)
          discuss response, "Unreleased #{@address} #{@version}", "Could not unrelease #{@address} #{@version}"
        end
      end

      private
      
      def validate!
        unless @username && @module_name
          abort "Username and Module name not provided"
        end
        begin
          Versionomy.parse(@version)
        rescue
          abort "Invalid version format: #{@version}"
        end
      end

    end
    
  end
end
