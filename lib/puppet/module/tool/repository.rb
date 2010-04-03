require 'net/http'
require 'digest/sha1'

module Puppet::Module::Tool

  class Repository
    include Utils::URI
    include Utils::Interrogation

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
      header "Authenticating for #{@uri}"
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
      @cache_key ||= [
                      @uri.to_s.gsub(/[^[:alnum:]]+/, '_').sub(/_$/, ''),
                      Digest::SHA1.hexdigest(@uri.to_s)
                    ].join('-')
    end
    
  end

end
