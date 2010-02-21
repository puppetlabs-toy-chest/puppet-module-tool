module PuppetModules

  class Cache
    include PuppetModules::Utils::URI

    def initialize(repository)
      @repository = repository
    end

    # TODO: Checksum support
    def retrieve(url)
      filename = File.basename(url.to_s)
      cached_file = path + filename
      unless cached_file.file?
        uri = normalize(url)
        data = uri.read
        cached_file.open('wb') { |f| f.write data }
        data
      end
      cached_file
    end

    def path
      @path ||=
        begin
          path = PuppetModules.dotdir + 'cache' + @repository.cache_key
          path.mkpath
          path
        end
    end

  end

end
