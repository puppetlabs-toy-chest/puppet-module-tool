module Puppet::Module::Tool
  module Applications

    class Registrar < Application
      # TODO Review whether the 'register' feature should be fixed or deleted.
=begin
      def initialize(full_name, options = {})
        @full_name = full_name
        @username, @module_name = full_name.split(/[\/\-]/, 2)
        super(options)
        validate!
      end

      def run
        if confirms?("Register #{@full_name}?")
          request = Net::HTTP::Post.new("/users/#{@username}/modules.json")
          request.set_form_data 'mod[name]' => @module_name
          response = repository.contact(request, :authenticate => true)
          discuss response, "Registered #{@full_name}", "Could not register #{@full_name}"
        end
      end

      private

      def validate!
        unless @username && @module_name
          abort "Must provide the full module name (ie, 'username/name') to register."
        end
      end
=end
    end
    
  end
end
