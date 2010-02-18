require 'puppet/applications/metadata_generator'
require 'fileutils'

module Puppet

  module Applications

    class ModuleBuilder

      def initialize(path, version)
        @path = path
        @version = version
        @metadata_generator = MetadataGenerator.new(@path)
        @pkg_path = File.join(@path, 'pkg')
      end

      def run
        create_directory
        copy_contents
        add_metadata
        tar
        gzip
        puts "Created #{@pkg_path}/#{module_name}.tar.gz"
      end

      private

      def tar
        Dir.chdir(@pkg_path) do
          FileUtils.rm "#{module_name}.tar" rescue nil
          unless system "tar -cf #{module_name}.tar #{module_name}"
            abort "Could not create TAR"
          end
        end
      end

      def gzip
        Dir.chdir(@pkg_path) do
          FileUtils.rm "#{module_name}.tar.gz" rescue nil
          unless system "gzip #{module_name}.tar"
            abort "Could not compress TAR"
          end
        end
      end

      def create_directory
        FileUtils.mkdir(@pkg_path) rescue nil
        FileUtils.rm_rf(build_path) rescue nil
        FileUtils.mkdir(build_path)
      end

      def copy_contents
        Dir[File.join(@path, '*')].each do |path|
          next if File.basename(path) == 'pkg'
          FileUtils.cp_r path, build_path
        end
      end

      def add_metadata
        File.open(File.join(build_path, 'metadata.json'), 'w') do |file|
          file.puts(PSON.dump(@metadata_generator.run))
        end
      end

      def module_name
        @module_name ||= File.basename(@path) + "-" + @version
      end

      def build_path
        @build_path ||= File.join(@pkg_path, module_name)
      end

    end

  end

end
