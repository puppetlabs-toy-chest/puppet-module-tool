module PuppetModules

  class Metadata

    attr_reader :full_name, :username, :name
    attr_accessor :version

    def initialize(settings = {})
      settings.each do |key, value|
        send("#{key}=", value)
      end
    end
    
    def full_name=(full_name)
      @full_name = full_name
      @username, @name = full_name.split(/[\/\-]/)
    end

    def dependencies
      @dependencies ||= []
    end

    def types
      @types ||= []
    end

    def checksums
      @checksums ||= {}
    end

    def dashed_name
      [@username, @name].join('-')
    end

    def release_name
      [@username, @name, @version].join('-')
    end

    def to_pson(*args)
      {
        :name         => @full_name,
        :version      => @version,
        :dependencies => dependencies,
        :types        => types,
        :checksums    => checksums
      }.to_pson(*args)
    end

  end
  
end
