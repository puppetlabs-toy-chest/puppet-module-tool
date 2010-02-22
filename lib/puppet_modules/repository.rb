require 'digest/sha1'

module PuppetModules

  class Repository
    include Utils::URI
    include Utils::Interrogation

    DEFAULT = 'http://modules.puppetlabs.com'

    attr_reader :uri, :cache
    def initialize(url=DEFAULT)
      @uri = normalize(url)
      @cache = Cache.new(self)
    end

    def contact(request, options = {}, &block)
      if options[:authenticate]
        authenticate(request)
      end
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        http.request(request)
      end
    end

    def authenticate(request)
      header "Authenticating for #{PuppetModules.repository}"
      email = prompt('Email Address')
      password = prompt('Password', true)
      request.basic_auth(email, password)
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
