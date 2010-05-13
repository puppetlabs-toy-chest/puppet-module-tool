module Puppet::Module::Tool

  # = Cache
  #
  # Provides methods for reading files from local cache, filesystem or network.
  class Cache
    include Puppet::Module::Tool::Utils::URI

    # Instantiate new cahe for the +repositry+ instance.
    def initialize(repository)
      @repository = repository
    end

    # Return filename retrieved from +uri+ instance. Will download this file and
    # cache it if needed.
    #
    # TODO: Add checksum support.
    # TODO: Add error checking.
    def retrieve(url)
      uri = normalize(url)
      filename = File.basename(uri.to_s)
      cached_file = path + filename
      unless cached_file.file?
        if uri.scheme == 'file'
          FileUtils.cp(uri.path, cached_file)
        else
          # TODO: Handle HTTPS; probably should use repository.contact
          data = read_retrieve(uri)
          cached_file.open('wb') { |f| f.write data }
        end
      end
      return cached_file
    end

    # Return contents of file at the given URI's +uri+.
    def read_retrieve(uri)
      return uri.read
    end

    # Return Pathname for repository's cache directory, create it if needed.
    def path
      return @path ||= (Puppet::Module::Tool.pmtdir + 'cache' + @repository.cache_key).tap{ |o| o.mkpath }
    end

  end

end
