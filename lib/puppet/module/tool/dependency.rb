module Puppet::Module::Tool

  class Dependency

    # Instantiates a new module dependency with a +full_name+ (e.g.
    # "myuser-mymodule"), and optional +version_requirement+ (e.g. "0.0.1") and
    # optional repository (a URL string).
    def initialize(full_name, version_requirement = nil, repository = nil)
      @full_name = full_name
      # TODO: add error checking, the next line raises ArgumentError when +full_name+ is invalid
      @username, @name = Puppet::Module::Tool.username_and_modname_from(full_name)
      @version_requirement = version_requirement
      @repository = repository ? Repository.new(repository) : Puppet::Module::Tool.repository
    end

    # Return PSON representation of this data.
    def to_pson(*args)
      {
        :name => @full_name,
        :version_requirement => @version_requirement,
        :repository => @repository.to_s
      }.to_pson(*args)
    end
    
  end
  
end
