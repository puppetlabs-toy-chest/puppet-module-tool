require 'pathname'
require 'tmpdir'

module PuppetModules

  module Applications

    class Unpacker < Application

      def initialize(filename, environment_path, force = false)
        @filename = Pathname.new(filename)
        @environment_path = Pathname.new(environment_path)
        @force = force
        parse_components!
      end

      def run
        check_clobber!
        build_dir = Pathname.new(File.join(Dir.tmpdir, "modules-#{Digest::SHA1.hexdigest(@filename.basename)}"))
        build_dir.mkpath
        begin
          FileUtils.cp @filename, build_dir
          filename = build_dir.children.first
          Dir.chdir(build_dir) do
            unless system "tar xzf #{@filename.basename}"
              abort "Could not extract contents of module archive."
            end
          end
          # grab the first directory
          extracted = build_dir.children.detect { |c| c.directory? }
          if @force
            FileUtils.rm_rf @module_name rescue nil
          end
          FileUtils.cp_r extracted, @module_name
          tag_revision
        ensure
          build_dir.rmtree
        end
        puts "Installed #{@username}/#{@module_name} #{@version} as #{@module_name}"
      end

      private

      def parse_components!
        @username, @module_name, @version = @filename.basename('.tar.gz').to_s.split('-', 3)
      end

      def tag_revision
        File.open("#{@module_name}/REVISION", 'w') do |f|
          f.puts "module: #{@username}/#{@module_name}"
          f.puts "version: #{@version}"
          f.puts "url: file://#{@filename.realpath}"
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

    end
    
  end
end
