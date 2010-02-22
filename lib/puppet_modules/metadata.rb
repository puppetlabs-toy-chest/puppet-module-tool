module PuppetModules

  class Metadata

    attr_reader :full_name, :username, :name
    attr_accessor :version
    
    def full_name=(full_name)
      @full_name = full_name
      @username, @name = full_name.split('/')
    end

    def dependencies
      @dependencies ||= []
    end

    def types
      @types ||= []
    end

    def to_pson(*args)
      {
        :name         => @full_name,
        :version      => @version,
        :dependencies => dependencies,
        :types        => types
      }.to_pson(*args)
    end
    
  end
  
end
