module Puppet::Module::Tool
  module Applications

    class Freezer < Application
      # TODO Review whether the 'freeze' feature should be fixed or deleted.
=begin
      def skeleton
        @skeleton ||= Skeleton.new
      end
        
      def run
        header "Freezing in #{skeleton.custom_path}"
        skeleton.freeze!
        say "Done.  Modify these files for the `generate` task."
      end
=end
    end
    
  end
end
