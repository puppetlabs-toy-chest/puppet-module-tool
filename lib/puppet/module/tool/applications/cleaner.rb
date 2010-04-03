module Puppet::Module::Tool
  module Applications

    class Cleaner < Application

      def run
        cache_path = Puppet::Module::Tool.pmtdir + "cache"
        cache_path.rmtree
        puts "Cleaned module cache."
      end

    end

  end
end
