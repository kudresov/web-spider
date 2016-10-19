require 'sinatra'
require 'neo4j'
require './models/resource.rb'
require 'nokogiri'
require 'addressable/uri'
require 'sidekiq/api'

require File.expand_path '../workers/page_downloader_worker.rb', __FILE__
require File.expand_path '../config/neo4j.rb', __FILE__

# require 'sidekiq/testing'
# Sidekiq::Testing.inline!

get '/' do
  erb :index
end

post '/crawl' do
  url = Addressable::URI.parse(params['url'])
  PageDownloaderWorker.perform_async(nil, url)
  redirect '/sidekiq'
end

get '/sitemap' do
  url = params['url']
  @page = Resource.find_by uri: url
  erb :sitemap
end

get '/status' do
  default_queue = Sidekiq::Queue.new
  puts default_queue.size
end