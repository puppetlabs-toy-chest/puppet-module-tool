module PuppetModules
  module Applications

    class Freezer < Application

      def initialize(*args)
        super
        @skeleton = Skeleton.new
      end
        
      def run
        header "Freezing in #{@skeleton.custom_path}"
        @skeleton.freeze!
        say "Done.  Modify these files for the `generate` task."
      end
      
    end
    
  end
end
