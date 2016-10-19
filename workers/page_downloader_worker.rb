require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'open-uri'
require 'nokogiri'
require 'neo4j'
require 'neo4j-core'
require 'addressable/uri'
require 'net/http'

require File.expand_path '../../models/resource.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__

neo_url = ENV['NEO4J_URL'] || 'http://neo4j:admin@localhost:7474'
Neo4j::Session.open(:server_db, neo_url)

Sidekiq.configure_client do |config|
  config.redis = { db: 1, size: 5}
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1, size: 27}
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
    node = build_node(parent_uri, uri)

    if node && node.is_crawlable?
      children_urls = get_child_resources Addressable::URI.parse(uri)
      children_urls.each {|url| self.class.perform_async(uri, url)}
    end
  end

  def build_node(parent_uri, node_uri)
    content_type = get_content_type node_uri
    begin
      parent = Resource.find_by(uri: parent_uri)
      resource = Resource.create uri: node_uri, content_type: content_type
      parent.resources << resource if parent
      resource
    rescue Neo4j::Server::CypherResponse::ConstraintViolationError => ex
      puts ex
      page = Resource.find_by uri: node_uri, content_type: content_type
      parent.resources << page
      nil
    end
  end

  def get_content_type(uri)
    parsed_uri  = Addressable::URI.parse(uri)
    parsed_uri.path = '/' if parsed_uri.path == '/'
    Net::HTTP.start(parsed_uri.host, parsed_uri.port){ |http| http.request_head(parsed_uri)['content-type'] }
  end
end
