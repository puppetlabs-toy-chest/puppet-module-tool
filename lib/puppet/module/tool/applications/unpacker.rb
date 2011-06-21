require 'pathname'
require 'tmpdir'

module Puppet::Module::Tool

  module Applications

    class Unpacker < Application

      def initialize(filename, environment_path, options = {})
        @filename = Pathname.new(filename)
        @environment_path = Pathname.new(environment_path)
        parse_filename!
        super(options)
      end

      def force?
        options[:force]
      end

      def run
        # Check if the module directory already exists.
        if File.exist?(@module_name) || File.symlink?(@module_name) then
          if force? then
            FileUtils.rm_rf @module_name rescue nil
          else
            check_clobber!
            # JJM 2011-06-20 And remove it anyway (This is a dumb way to do it, but...  it works.)
            FileUtils.rm_rf @module_name rescue nil
          end
        end
        build_dir = Puppet::Module::Tool::Cache.base_path + "tmp-unpacker-#{Digest::SHA1.hexdigest(@filename.basename.to_s)}"
        build_dir.mkpath
        begin
          FileUtils.cp @filename, build_dir
          Dir.chdir(build_dir) do
            unless system "tar xzf #{@filename.basename}"
              abort "Could not extract contents of module archive."
            end
          end
          # grab the first directory
          extracted = build_dir.children.detect { |c| c.directory? }
          # Nothing should exist at this point named @module_name
          FileUtils.cp_r extracted, @module_name
          tag_revision
        ensure
          build_dir.rmtree
        end
        say "Installed #{@release_name.inspect} into directory: #{@module_name}"
      end

      private

      def tag_revision
        File.open("#{@module_name}/REVISION", 'w') do |f|
          f.puts "module: #{@username}/#{@module_name}"
          f.puts "version: #{@version}"
          f.puts "url: file://#{@filename.realpath}"
          f.puts "installed: #{Time.now}"
        end
      end

      def check_clobber!
        if (File.exist?(@module_name) || File.symlink?(@module_name)) && !force?
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
