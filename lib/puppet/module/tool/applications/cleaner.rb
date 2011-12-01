module Puppet::Module::Tool
  module Applications

    class Cleaner < Application

      def run
        Puppet::Module::Tool::Cache.clean
        puts "Cleaned module cache."
      end

    end

  end
end
