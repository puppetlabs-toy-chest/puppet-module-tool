require 'pathname'
require 'fileutils'
require 'erb'

module PuppetModules
  module Applications

    class Generator < Application

      class Node
        def initialize(generator, source)
          @generator = generator
          @source = source
        end
        def read
          @source.read
        end
        def target
          target = @generator.destination + @source.relative_path_from(@generator.skeleton)
          components = target.to_s.split(File::SEPARATOR).map do |part|
            part == 'NAME' ? @generator.metadata.name : part
          end
          Pathname.new(components.join(File::SEPARATOR))
        end
        def install!
          raise NotImplementedError, "Abstract"
        end
      end

      class DirectoryNode < Node
        def install!
          target.mkpath
        end
      end

      class FileNode < Node
        def install!
          FileUtils.cp(@source, target)
        end
      end

      class ParsedFileNode < Node
        def target
          path = super
          path.parent + path.basename('.erb')
        end
        def contents
          template = ERB.new(read)
          template.result(@generator.send(:binding))
        end
        def install!
          target.open('w') { |f| f.write contents }
        end
      end

      def initialize(full_name)
        @metadata = Metadata.new(:full_name => full_name)
      end
      
      def run
        if destination.directory?
          abort "#{destination} already exists."
        end
        header "Generating module at #{Dir.pwd}/#{@metadata.dashed_name}"
        skeleton.find do |path|
          if path == skeleton
            destination.mkpath
          else
            n = node(path)
            n.install!
            say n.target
          end
        end
      end
      
      def destination
        @destination ||= Pathname.new(@metadata.dashed_name)
      end

      def skeleton
        @skeleton ||= PuppetModules.root + 'templates' + 'generator'
      end

      def node(path)
        if path.directory?
          DirectoryNode.new(self, path)
        elsif path.extname == '.erb'
          ParsedFileNode.new(self, path)
        else
          FileNode.new(self, path)
        end
      end

    end
    
  end
end
