module PuppetModules

  module Applications

    class Releaser < Application

      requires 'puppet', ['net/http/post/multipart', 'multipart_post']
      
      def initialize(address, filename, version = nil)
        @filename = filename
        @username, @module_name = address.split('/')
        @version = version || parse_version
        validate!
      end

      def run
        upload if verify
      end

      private

      def upload
        File.open(@filename) do |file|
          req = request("/users/#{@username}/modules/#{@module_name}/releases.json", file)
          res = PuppetModules.repository.contact(req, :authenticate => true)
          puts "\n---"
          if res.is_a?(Net::HTTPOK)
            puts "Released #{@version}"
          else
            error = PSON.parse(res.body)['error'] rescue "HTTP #{res.code}"
            puts "Could not release #{@version} (#{error})"
          end
        end
      end

      def verify
        print "Release #{File.basename(@filename)} as version #{@version} of #{@username}/#{@module_name} [y/N]: "
        $stdin.gets =~ /y/i
      end

      def request(path, file)
        upload = UploadIO.new(file, 'application/x-gzip', @filename)
        Net::HTTP::Post::Multipart.new(path,
                                       'release[version]' => @version,
                                       'release[file]'    => upload)
      end

      def parse_version
        name = File.basename(@filename, '.tar.gz')
        name.split('-', 3).last
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

    end
    
  end
end
