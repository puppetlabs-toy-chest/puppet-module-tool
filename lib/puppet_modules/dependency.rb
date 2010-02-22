module PuppetModules

  class Dependency

    def initialize(full_name, version_requirement = nil, repository = nil)
      @full_name = full_name
      @username, @name = full_name.split('/')
      @version_requirement = version_requirement
      @repository = repository ? Repository.new(repository) : PuppetModules.repository
    end

    def to_pson(*args)
      {
        :name => @full_name,
        :version_requirement => @version_requirement,
        :repository => @repository.to_s
      }.to_pson(*args)
    end
    
  end
  
end
