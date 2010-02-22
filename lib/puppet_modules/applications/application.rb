module PuppetModules
  module Applications

    class Application
      extend Utils::WhinyRequire
      include Utils::Interrogation

      def self.requires(*requires)
        whiny_require(*requires)
      end

      def self.run(*args)
        new(*args).run
      end

      def repository
        PuppetModules.repository
      end

      def run
        raise NotImplementedError, "Should be implemented in child classes."
      end
      
    end

  end
end
