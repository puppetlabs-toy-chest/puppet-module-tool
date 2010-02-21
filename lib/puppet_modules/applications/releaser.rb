module PuppetModules

  module Applications

    class Releaser < Application

      requires ['net/http/post/multipart', 'multipart_post']
      
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
          url = PuppetModules.repository.uri + "/users/#{@username}/modules/#{@module_name}/releases.json"
          req = request(url, file)
          email, password = authenticate
          req.basic_auth(email, password)
          puts
          header "Releasing to #{PuppetModules.repository}"
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end
          if res.is_a?(Net::HTTPOK)
            puts "Released #{@version}"
          else
            puts "Could not release #{@version} (HTTP #{res.code})"
          end
        end
      end

      def verify
        print "Release #{File.basename(@filename)} as version #{@version} of #{@username}/#{@module_name} [y/N]: "
        $stdin.gets =~ /y/i
      end

      def authenticate
        header "Authenticating for #{PuppetModules.repository}"
        email = prompt('Email Address')
        password = prompt('Password', true)
        [email, password]
      end

      def request(url, file)
        upload = UploadIO.new(file, 'application/x-gzip', @filename)
        Net::HTTP::Post::Multipart.new(url.path,
                                       'release[version]' => @version,
                                       'release[file]'    => upload)
      end

      def header(text)
        puts('=' * text.size, text, "-" * text.size)
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

      def prompt(question, quiet = false)
        print "#{question}: "
        system 'stty -echo' if quiet
        $stdin.gets.strip
      ensure
        system 'stty echo' if quiet
      end

    end
    
  end
end
