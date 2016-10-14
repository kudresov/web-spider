require 'nokogiri'

class LinkExtractor
  LINKS_XPATH = '//body//a'

  def initialize(html)
    @html = html
  end

  def get_raw_links
    doc = Nokogiri::HTML(@html)
    doc.xpath(LINKS_XPATH).map { |link| link['href'] }
  end
end