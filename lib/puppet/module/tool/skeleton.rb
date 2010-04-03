module Puppet::Module::Tool

  class Skeleton

    def freeze!
      FileUtils.rm_fr custom_path rescue nil
      FileUtils.cp_r default_path, custom_path
    end

    def path 
      paths.detect { |path| path.directory? }
    end

    def paths
      @paths ||= [
                  custom_path,
                  default_path
                 ]
    end

    def custom_path
      Puppet::Module::Tool.pmtdir + 'skeleton'
    end
    
    def default_path
      Puppet::Module::Tool.root + 'templates' + 'generator'
    end

  end

end
