require 'open-uri'
require 'pathname'
require 'tmpdir'

module PuppetModules

  module Applications

    class Installer < Application

      def initialize(name, version_requirement = nil, force = false)
        @username, @module_name = name.split('/')
        @version_requirement = version_requirement
        @force = force
      end

      def run
        check_clobber!
        match = find_match
        if match['file']
          cache_path = PuppetModules.repository.retrieve(match['file'])
          build_dir = Pathname.new(File.join(Dir.tmpdir, "modules-#{Digest::SHA1.hexdigest(match['file'])}"))
          build_dir.mkpath
          begin
            FileUtils.cp cache_path, build_dir
            filename = build_dir.children.first
            Dir.chdir(build_dir) do
              unless system "tar xzf #{filename.basename}"
                abort "Could not extract contents of module archive."
              end
            end
            # grab the first directory
            extracted = build_dir.children.detect { |c| c.directory? }
            if @force
              FileUtils.rm_rf @module_name rescue nil
            end
            FileUtils.cp_r extracted, @module_name
            tag_revision(match['version'])
          ensure
            build_dir.rmtree
          end
          puts "Installed #{@username}/#{@module_name} #{match['version']} as #{@module_name}"
        else
          abort "Malformed response from module repository."
        end
      end

      private

      def tag_revision(version)
        File.open("#{@module_name}/REVISION", 'w') do |f|
          f.puts "module: #{@username}/#{@module_name}"
          f.puts "version: #{version}"
          f.puts "url: #{repository.uri + "#{@username}/#{@module_name}/#{version}"}"
          f.puts "installed: #{Time.now}"
        end
      end

      def check_clobber!
        if File.directory?(@module_name) && !@force
          header "Existing module '#{@module_name}' found"
          response = prompt "Overwrite module installed at ./#{@module_name}? [y/N]"
          unless response =~ /y/i
            abort "Aborted installation."
          end
        end
      end

      def find_match
        url = PuppetModules.repository.uri + "/users/#{@username}/modules/#{@module_name}/releases/find.json"
        if @version_requirement
          url.query = "version=#{URI.escape(@version_requirement)}"
        end
        begin
          raw_result = url.read
        rescue => e
          abort "Could not request version match (#{e.message})"
        end
        PSON.parse(raw_result)
      end

    end
    
  end
end
