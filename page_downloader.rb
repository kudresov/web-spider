require 'open-uri'
require 'nokogiri'
require File.expand_path '../link_extractor.rb', __FILE__

url = 'https://en.wikipedia.org'
link_xpath = '//body//a'
fh = open(url)
html = fh.read
link_extractor = LinkExtractor.new(html)
links = link_extractor.get_crawlable_domain_links('wikipedia.org', 'https')


# doc = Nokogiri::HTML(html)
# links = doc.xpath(link_xpath).map { |link| link['href'] }
puts links.count