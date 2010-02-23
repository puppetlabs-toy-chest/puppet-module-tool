require 'fileutils'

module PuppetModules

  module Applications

    class Builder < Application

      ARTIFACTS = ['pkg', /^\./, /^~/, /^#/]

      def initialize(path)
        @path = path
        @pkg_path = File.join(@path, 'pkg')
      end

      def run
        load_modulefile!
        create_directory
        copy_contents
        add_metadata
        header 'Building tarball'
        tar
        gzip
        say filename('tar.gz')
      end

      private

      def filename(ext)
        ext.sub!(/^\./, '')
        "#{metadata.release_name}.#{ext}"
      end

      def tar
        tar_name = filename('tar')
        Dir.chdir(@pkg_path) do
          FileUtils.rm tar_name rescue nil
          unless system "tar -cf #{tar_name} #{metadata.release_name}"
            abort "Could not create #{tar_name}"
          end
        end
      end

      def gzip
        Dir.chdir(@pkg_path) do
          FileUtils.rm filename('tar.gz') rescue nil
          unless system "gzip #{filename('tar')}"
            abort "Could not compress #{filename('tar')}"
          end
        end
      end

      def create_directory
        FileUtils.mkdir(@pkg_path) rescue nil
        if File.directory?(build_path)
          FileUtils.rm_rf(build_path)
        end
        FileUtils.mkdir(build_path)
      end

      def copy_contents
        Dir[File.join(@path, '*')].each do |path|
          case File.basename(path)
          when *ARTIFACTS
            next
          else
            FileUtils.cp_r path, build_path
          end
        end
      end

      def add_metadata
        File.open(File.join(@path, 'metadata.json'), 'w') do |f|
          f.write PSON.dump(metadata)
        end
      end

      def build_path
        @build_path ||= File.join(@pkg_path, metadata.release_name)
      end

    end

  end

end
