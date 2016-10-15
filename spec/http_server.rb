#!/usr/bin/env ruby

require 'webrick'

puts 'here'
path = ARGV[0]
server = WEBrick::HTTPServer.new(
    Port: 8000,
    DocumentRoot: path
)

server.start