module Puppet::Module::Tool

  module Applications

    class Searcher < Application

      def initialize(term, options = {})
        @term = term
        super(options)
      end

      def run
        header "Searching #{repository}"
        request = Net::HTTP::Get.new("/modules.json?q=#{URI.escape(@term)}")
        response = repository.contact(request)
        case response
        when Net::HTTPOK
          matches = PSON.parse(response.body)
          if matches.empty?
            subheader "0 found."
          else
            subheader "#{matches.size} found."
          end
          matches.each do |match|
            puts "#{match['name']} (#{match['version']})"
          end
        else
          say "Could not execute search (HTTP #{response.code})"
        end
      end
      
    end
  end
end
