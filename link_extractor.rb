require 'nokogiri'
require 'addressable/uri'
require 'public_suffix'
require 'addressable/uri'

class LinkExtractor
  LINKS_XPATH = '//html//a'

  def initialize(html)
    @html = html
  end

  def get_raw_links
    doc = Nokogiri::HTML(@html)
    doc.xpath(LINKS_XPATH).map { |link| link['href'] }
  end

  def get_crawlable_domain_links(host, scheme, port = nil)
    uris = get_raw_links.compact.map {|link| self.class.build_crawlable_link(link, host, scheme, port)}
    uris.select {|uri| PublicSuffix.domain(uri.host) == host || uri.host == 'localhost'}.uniq
  end

  def self.build_crawlable_link(url, host, scheme, port = nil)
    begin
      parsed_uri = Addressable::URI.parse(url)
      parsed_uri.host ||= host
      parsed_uri.scheme ||= scheme
      parsed_uri.fragment = nil
      parsed_uri.port ||= port
      parsed_uri.path = nil if parsed_uri.path == '/'
      parsed_uri
    rescue Addressable::URI::InvalidURIError => ex
      puts ex
      # If the uri failed to parse it might it not complying with RFC standart
      # we will try to parse it one more time using heuristic
      Addressable::URI.heuristic_parse(url, {scheme: scheme})
    rescue
      nil
    end
  end
end