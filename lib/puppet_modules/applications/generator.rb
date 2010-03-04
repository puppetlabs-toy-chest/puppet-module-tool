require 'pathname'
require 'fileutils'
require 'erb'

module PuppetModules
  module Applications

    class Generator < Application

      attr_reader :skeleton
      def initialize(full_name)
        @metadata = Metadata.new(:full_name => full_name)
        @skeleton = Skeleton.new
      end
      
      def run
        if destination.directory?
          abort "#{destination} already exists."
        end
        header "Generating module at #{Dir.pwd}/#{@metadata.dashed_name}"
        skeleton.path.find do |path|
          if path == skeleton
            destination.mkpath
          else
            node = Node.on(path, self)
            if node
              node.install!
              say node.target
            else
              say "Could not generate from #{path}"
            end
          end
        end
      end
      
      def destination
        @destination ||= Pathname.new(@metadata.dashed_name)
      end

      class Node
        def self.types
          @types ||= []
        end
        def self.inherited(klass)
          types << klass
        end
        def self.on(path, generator)
          klass = types.detect { |t| t.matches?(path) }
          if klass
            klass.new(path, generator)
          end
        end
        def initialize(source, generator)
          @generator = generator
          @source = source
        end
        def read
          @source.read
        end
        def target
          target = @generator.destination + @source.relative_path_from(@generator.skeleton.path)
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
        def self.matches?(path)
          path.directory?
        end
        def install!
          target.mkpath
        end
      end

      class ParsedFileNode < Node
        def self.matches?(path)
          path.file? && path.extname == '.erb'
        end
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

      class FileNode < Node
        def self.matches?(path)
          path.file?
        end
        def install!
          FileUtils.cp(@source, target)
        end
      end
      
    end
    
  end
end
