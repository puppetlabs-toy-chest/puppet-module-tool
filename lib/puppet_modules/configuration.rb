module PuppetModules
  class Configuration

    autoload :DSL, 'puppet_modules/configuration/dsl'
    
    def self.evaluate(file)
      config = new
      if file.exist?
        dsl = DSL.new(config)
        dsl.instance_eval(file.read, file.realpath, 1)
      end
      config
    end

    def repository
      @repository ||= Repository.new
    end
  
    def repository=(url)
      @repository = Repository.new(url)
    end

  end
end

