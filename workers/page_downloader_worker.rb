require 'sidekiq'
require 'open-uri'
require 'nokogiri'
require 'addressable/uri'
require 'net/http'

require File.expand_path '../../models/resource.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__
require File.expand_path '../../config/sidekiq.rb', __FILE__
require File.expand_path '../../config/neo4j.rb', __FILE__

class PageDownloaderWorker
  include Sidekiq::Worker
  def get_child_resources(uri)
    fh = open(uri.to_s)
    html = fh.read
    link_extractor = LinkExtractor.new(html)
    logger.info "getting children for #{uri}"
    link_extractor.get_crawlable_domain_links(uri.host, uri.scheme, uri.port)
  end

  def perform(parent_uri, uri)
    logger.info "processing #{uri}"
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
      logger.error ex
      page = Resource.find_by uri: node_uri, content_type: content_type
      parent.resources << page if parent
      nil
    end
  end

  # we use get content type rather than downloading the resource as image and html can be fairly large and the are no need to download
  # it if it's an image, so we use HEAD request instead to what is the content type
  def get_content_type(uri)
    # TODO double check that open, doesn't make a get request, otherwise use a lower level lib like Net::HTTP
    req = open(uri)
    req.content_type
  end
end
