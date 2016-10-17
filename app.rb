require 'sinatra'
require 'neo4j'
require './models/resource.rb'
require 'nokogiri'
require 'addressable/uri'

require File.expand_path '../workers/page_downloader_worker.rb', __FILE__

Neo4j::Session.open(:server_db, ENV['NEO4J_URL'])

get '/' do
  erb :index
end

post '/crawl' do
  url = Addressable::URI.parse(params['url'])
  PageDownloaderWorker.perform_async(nil, url)
end

