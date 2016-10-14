require 'open-uri'
require 'nokogiri'

url = 'https://en.wikipedia.org'
link_xpath = '//body//a'
fh = open(url)
html = fh.read
doc = Nokogiri::HTML(html)
links = doc.xpath(link_xpath).map { |link| link['href'] }
puts links