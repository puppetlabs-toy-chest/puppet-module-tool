require 'net/http/post/multipart'
require 'versionomy'

module PuppetModules

  module Applications

    class Releaser < Application

      def initialize(filename)
        @filename = filename
        parse_filename!
        validate!
      end

      def run
        upload if confirms?("Release #{File.basename(@filename)} as version #{@version} of #{@username}/#{@module_name}?")
      end

      private

      def upload
        File.open(@filename) do |file|
          request = build_request(file)
          response = PuppetModules.repository.contact(request, :authenticate => true)
          discuss response, "Released #{@version}", "Could not release #{@version}"
        end
      end

      def build_request(file)
        upload = UploadIO.new(file, 'application/x-gzip', @filename)
        Net::HTTP::Post::Multipart.new(upload_path,
                                       'release[version]' => @version,
                                       'release[file]'    => upload)
      end

      def upload_path
        "/users/#{@username}/modules/#{@module_name}/releases.json"
      end

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

      def parse_filename!
        @username, @module_name, @version = File.basename(@filename,'.tar.gz').split('-', 3)
      end

    end
    
  end
end
