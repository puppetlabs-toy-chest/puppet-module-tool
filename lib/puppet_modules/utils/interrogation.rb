module PuppetModules
  module Utils
    module Interrogation

      def header(text)
        $stderr.puts('=' * text.size, text, "-" * text.size)
      end

      def say(*args)
        $stderr.puts(*args)
      end

      def subheader(line)
        say line, ('-' * line.size)
      end

      def confirms?(question)
        $stderr.print "#{question} [y/N]: "
        $stdin.gets =~ /y/i
      end

      def prompt(question, quiet = false)
        $stderr.print "#{question}: "
        system 'stty -echo' if quiet
        $stdin.gets.strip
      ensure
        if quiet
          system 'stty echo'
          say "\n---------"
        end
      end

    end
  end
end
