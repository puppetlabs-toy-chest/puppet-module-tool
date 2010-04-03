module Puppet::Module::Tool
  module Applications

    class Registrar < Application

      def initialize(full_name)
        @username, @module_name = full_name.split(/[\/\-]/, 2) 
        validate!
      end

      def run
        abort "Sorry, this doesn't work yet."
      end

      private

      def validate!
        unless @username && @module_name
          abort "Must provide the full module name (ie, 'username/name') to register."
        end
      end
      
    end
    
  end
end
