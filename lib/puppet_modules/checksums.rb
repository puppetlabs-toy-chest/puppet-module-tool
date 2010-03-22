require 'digest/md5'

module PuppetModules
  class Checksums

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
          if PuppetModules.artifact?(descendant)
            Find.prune
          elsif descendant.file?
            path = descendant.relative_path_from(@path)
            @data[path.to_s] = checksum(descendant)
          end
        end
      end
      @data
    end

    def annotate(metadata)
      metadata.checksums.replace(data)
    end
    
  end
end
