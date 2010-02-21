module PuppetModules
  module Applications

    class Application
      extend PuppetModules::Utils::WhinyRequire

      def self.requires(*requires)
        whiny_require(*requires)
      end

      def self.run(*args)
        new(*args).run
      end

      def run
        raise NotImplementedError, "Should be implemented in child classes."
      end
      
    end

  end
end
