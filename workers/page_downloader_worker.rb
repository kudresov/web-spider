require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'open-uri'
require 'nokogiri'
require 'neo4j'
require 'neo4j-core'
require 'addressable/uri'

require File.expand_path '../../models/resource.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__

Neo4j::Session.open(:server_db, ENV['NEO4J_URL'])

Sidekiq.configure_client do |config|
  config.redis = { db: 1, size: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1, size: 19 }
end

class PageDownloaderWorker
  include Sidekiq::Worker
  def get_child_resources(uri)
    fh = open(uri.to_s)
    html = fh.read
    link_extractor = LinkExtractor.new(html)
    puts "getting children for #{uri}"
    link_extractor.get_crawlable_domain_links(uri.host, uri.scheme, uri.port)
  end

  def perform(parent_uri, uri)
    puts "processing #{uri}"
    begin
      parent = Resource.find_by(uri: parent_uri)
      resource = Resource.create uri: uri
      parent.resources << resource if parent
      children_urls = get_child_resources Addressable::URI.parse(uri)
      children_urls.each {|url| self.class.perform_async(uri, url)}
    rescue Neo4j::Server::CypherResponse::ConstraintViolationError => ex
      puts ex
      page = Resource.find_by uri: uri
      parent.resources << page
    end
  end
end
