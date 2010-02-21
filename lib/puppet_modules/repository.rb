require 'digest/sha1'

module PuppetModules

  class Repository
    include Utils::URI

    DEFAULT = 'http://modules.puppetlabs.com'

    attr_reader :uri, :cache
    def initialize(url=DEFAULT)
      @uri = normalize(url)
      @cache = Cache.new(self)
    end

    def retrieve(path)
      cache.retrieve(@uri + path)
    end

    def to_s
      @uri.to_s
    end

    def cache_key
      @cache_key ||= Digest::SHA1.hexdigest(@uri.to_s)
    end
    
  end

end
