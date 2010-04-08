require 'digest/md5'

module Puppet::Module::Tool
  class Checksums
    include Enumerable

    def initialize(path)
      @path = Pathname.new(path)
    end

    def checksum(path)
      Digest::MD5.hexdigest(path.read)
    end

    def data
      unless @data
        @data = {}
        @path.find do |descendant|
          if Puppet::Module::Tool.artifact?(descendant)
            Find.prune
          elsif descendant.file?
            path = descendant.relative_path_from(@path)
            @data[path.to_s] = checksum(descendant)
          end
        end
      end
      @data
    end

    def each(&block)
      data.each(&block)
    end

    def annotate(metadata)
      metadata.checksums.replace(data)
    end
    
  end
end
