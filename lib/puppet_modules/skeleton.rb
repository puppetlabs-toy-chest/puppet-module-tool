module PuppetModules

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
      PuppetModules.dotdir + 'skeleton'
    end
    
    def default_path
      PuppetModules.root + 'templates' + 'generator'
    end

  end

end
