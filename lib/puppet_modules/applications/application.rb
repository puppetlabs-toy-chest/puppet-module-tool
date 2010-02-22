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

      private

      def header(text)
        puts('=' * text.size, text, "-" * text.size)
      end

      def prompt(question, quiet = false)
        print "#{question}: "
        system 'stty -echo' if quiet
        $stdin.gets.strip
      ensure
        system 'stty echo' if quiet
      end

      
    end

  end
end
