module Puppet::Module::Tool
  module Applications

    class Checksummer < Application

      def initialize(path, options = {})
        @path = Pathname.new(path)
        super(options)
      end

      def run
        if metadata_file.exist?
          sums = Checksums.new(@path)
          (metadata['checksums'] || {}).each do |child_path, canonical_checksum|
            path = @path + child_path
            if canonical_checksum != sums.checksum(path)
              say child_path
            end
          end
        else
          abort "No metadata.json found."
        end
      end

      private

      def metadata
        PSON.parse(metadata_file.read)
      end

      def metadata_file
        (@path + 'metadata.json')
      end

    end

  end
end
