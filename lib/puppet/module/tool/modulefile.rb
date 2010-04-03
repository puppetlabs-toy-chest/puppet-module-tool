module Puppet::Module::Tool

  class Modulefile

    def self.evaluate(metadata, filename)
      builder = new(metadata)
      if File.file?(filename)
        builder.instance_eval(File.read(filename.to_s), filename.to_s, 1)
      else
        puts "No Modulefile: #{filename}"
      end
      builder
    end
    
    def initialize(metadata)
      @metadata = metadata
    end

    def name(name)
      @metadata.full_name = name
    end

    def version(version)
      @metadata.version = version
    end

    def dependency(name, version_requirement = nil, repository = nil)
      @metadata.dependencies << Dependency.new(name, version_requirement, repository)
    end

  end

end
