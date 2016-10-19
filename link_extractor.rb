require 'nokogiri'
require 'addressable/uri'
require 'public_suffix'
require 'addressable/uri'

class LinkExtractor
  LINKS_XPATH = '//html//a'
  IMAGES_XPATH = '//html//img'
  CSS_XPATH = '//link'

  def initialize(html)
    @doc = Nokogiri::HTML(html)
  end

  # TODO dry up the 3 methods below
  def get_raw_links
    @doc.xpath(LINKS_XPATH).map { |link| link['href'] }
  end

  def get_image_links
    @doc.xpath(IMAGES_XPATH).map { |img| img['src'] }
  end

  def get_css_links
    @doc.xpath(CSS_XPATH).map { |css| css['href'] }
  end

  def get_crawlable_domain_links(host, scheme, port = nil)
    resources = get_image_links + get_raw_links + get_css_links
    uris = resources.compact.map {|link| self.class.build_crawlable_link(link, host, scheme, port)}
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