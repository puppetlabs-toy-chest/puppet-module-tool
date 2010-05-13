module Puppet::Module::Tool
  module Utils

    # = Interrogation
    #
    # This module contains methods to emit text to the console, such as headers.
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
