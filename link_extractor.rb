require 'nokogiri'
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

  def get_domain_links(domain)

  end

  def self.parse_link(url, host, scheme)
    parsed_uri = Addressable::URI.parse(url)
    parsed_uri.host ||= host
    parsed_uri.scheme ||= scheme
    parsed_uri.fragment = nil
    parsed_uri
  end
end