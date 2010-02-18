require 'net/http/post/multipart'                                                                                                          

module Puppet
  module Applications

    class ModuleReleaser

      def initialize(repository, filename)
        @repository = repository
        @filename = filename
        parse
        validate!
      end

      def run
        upload if verify 
      end

      private

      def upload
        File.open(@filename) do |file|
          url = @repository + "/users/#{@username}/modules/#{@module_name}/releases.json"
          req = request(url, file)
          email, password = prompt
          req.basic_auth(email, password)
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end
          if res.is_a?(Net::HTTPOK)
            puts "Released #{@version}"
          else
            puts "Could not release #{@version}"
          end
        end
      end

      def verify
        print "Release version #{@version} of #{@username}/#{@module_name} [y/N]: "
        $stdin.gets =~ /y/i
      end

      def prompt
        print "Email Address: "
        email = $stdin.gets.strip
        print "Password: "
        password = $stdin.gets.strip
        [email, password]
      end

      def request(url, file)
        upload = UploadIO.new(file, 'application/x-gzip', @filename)
        Net::HTTP::Post::Multipart.new(url.path,
                                       'release[version]' => @version,
                                       'release[file]'    => upload)
      end

      def parse
        simple = File.basename(@filename, '.tar.gz')
        @username, @module_name, @version = simple.split('-', 3)
      end

      def validate!
        unless @username && @module_name && @version
          abort "Can not determine username, module name, and version from filename"
        end
      end

    end
    
  end
end
