require 'sinatra'
require 'neo4j'
require './models/resource.rb'
require 'nokogiri'
require 'addressable/uri'

require File.expand_path '../workers/page_downloader_worker.rb', __FILE__

neo4j_url = ENV['NEO4J_URL'] || 'http://localhost:7474'
neo4j_username = ENV['NEO4J_USERNAME'] || 'neo4j'
neo4j_password = ENV['NEO4J_PASSWORD'] || 'admin'

Neo4j::Session.open(:server_db, neo4j_url, basic_auth: {username: neo4j_username, password: neo4j_password})

get '/' do
  erb :index
end

post '/crawl' do
  url = Addressable::URI.parse(params['url'])
  PageDownloaderWorker.perform_async(nil, url)
end