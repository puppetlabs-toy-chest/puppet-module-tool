require 'net/http/post/multipart'

module Puppet::Module::Tool

  module Applications

    class Releaser < Application
      # TODO Review whether the 'release' feature should be fixed or deleted.
=begin
      def initialize(filename, options = {})
        @filename = filename
        parse_filename!
        super(options)
      end

      def version
        @version ||= options[:version]
      end

      def run
        upload if confirms?("Release #{File.basename(@filename)} as version #{version} of #{@username}/#{@module_name}?")
      end

      private

      def upload
        File.open(@filename) do |file|
          request = build_request(file)
          response = repository.contact(request, :authenticate => true)
          discuss response, "Released #{version}", "Could not release #{version}"
        end
      end

      def build_request(file)
        upload = UploadIO.new(file, 'application/x-gzip', @filename)
        Net::HTTP::Post::Multipart.new(upload_path,
                                       'release[version]' => version,
                                       'release[file]'    => upload)
      end

      def upload_path
        "/users/#{@username}/modules/#{@module_name}/releases.json"
      end
=end
    end

  end
end
