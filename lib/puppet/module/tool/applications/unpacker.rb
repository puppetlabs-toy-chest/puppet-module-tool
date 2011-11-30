require 'pathname'
require 'tmpdir'

module Puppet::Module::Tool

  module Applications

    class Unpacker < Application

      def initialize(filename, options = {})
        @filename = Pathname.new(filename)
        parse_filename!
        super(options)
        @module_dir = Puppet::Module::Tool.install_dir + @module_name
      end

      def run
        extract_module_to_install_dir
        tag_revision
        say "Installed #{@release_name.inspect} into directory: #{@module_dir.expand_path}"
      end

      private

      def tag_revision
        File.open("#{@module_dir}/REVISION", 'w') do |f|
          f.puts "module: #{@username}/#{@module_name}"
          f.puts "version: #{@version}"
          f.puts "url: file://#{@filename.expand_path}"
          f.puts "installed: #{Time.now}"
        end
      end

      def extract_module_to_install_dir
        delete_existing_installation_or_abort!

        build_dir = Puppet::Module::Tool::Cache.base_path + "tmp-unpacker-#{Digest::SHA1.hexdigest(@filename.basename.to_s)}"
        build_dir.mkpath
        begin
          say "Installing #{@filename} to #{@module_dir.expand_path}"
          unless system "tar xzf #{@filename} -C #{build_dir}"
            abort "Could not extract contents of module archive."
          end
          # grab the first directory
          extracted = build_dir.children.detect { |c| c.directory? }
          FileUtils.mv extracted, @module_dir
        ensure
          build_dir.rmtree
        end
      end

      def delete_existing_installation_or_abort!
        return unless @module_dir.exist?

        if !options[:force]
          header "Existing module '#{@module_dir.expand_path}' found"
          response = prompt "Overwrite module installed at #{@module_dir.expand_path}? [y/N]"
          unless response =~ /y/i
            abort "Aborted installation."
          end
        end

        say "Deleting #{@module_dir.expand_path}"
        FileUtils.rm_rf @module_dir
      end
    end
  end
end
