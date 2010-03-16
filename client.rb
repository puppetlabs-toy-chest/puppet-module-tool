#!/usr/bin/env ruby

require 'open-uri'

server = URI.parse('http://localhost:3000')

class Query < String

  def initialize(raw)
    super("q=#{sanitize(raw)}")
  end

  private

  def sanitize(raw)
    raw.split('-').reject { |s| s == '*' }.join('-')
  end

end

address = server + '/mods.json'
address.query = Query.new(ARGV.first)
puts address

