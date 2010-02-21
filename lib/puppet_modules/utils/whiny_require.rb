module PuppetModules
  module Utils
    
    module WhinyRequire
      
      def whiny_require(*requires)
        requires.each do |req|
          path, library = Array(req)
          library ||= path
          begin
            require path
          rescue LoadError
            abort "Requires the '#{library}' library."
          end
        end
      end
      
    end
    
  end
end
