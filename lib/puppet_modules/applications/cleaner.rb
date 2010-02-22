module PuppetModules
  module Applications

    class Cleaner < Application

      def run
        cache_path = PuppetModules.dotdir + "cache"
        cache_path.rmtree
        puts "Cleaned module cache."
      end

    end

  end
end
