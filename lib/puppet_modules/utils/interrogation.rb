module PuppetModules
  module Utils
    module Interrogation

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
