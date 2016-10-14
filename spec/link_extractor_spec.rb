require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__

describe 'Link extractor' do

  describe 'get_raw_links' do

    test_data = [
        {page: 'one_link.html', expected_links_count: 1},
        {page: 'three_links.html', expected_links_count: 3},
        {page: 'malformed_body.html', expected_links_count: 1},
        {page: 'relative_links.html', expected_links_count: 6},
        {page: 'email_link.html', expected_links_count: 2}
    ]

    test_data.each do |data|
      it "should give #{data[:expected_links_count]} link/s for a #{data[:page]}" do
        # arrange
        html_path = File.expand_path('../web/' + data[:page], __FILE__)
        html = File.read(html_path)
        link_extractor = LinkExtractor.new(html)

        # act
        raw_links = link_extractor.get_raw_links

        # assert
        expect(raw_links.count).to eq(data[:expected_links_count])
      end
    end
  end

  describe 'get_domain_links' do
    it 'should give one link for domain' do
      # arrange
      html_path = File.expand_path('../web/one_link.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_domain_links('google.com')

      # assert
      expect(domain_links.count).to eq(1)
    end

    it 'should give one link for three links page' do
      # arrange
      html_path = File.expand_path('../web/three_links.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_domain_links('google.com')

      # assert
      expect(domain_links.count).to eq(2)
    end
  end

  describe 'parse_link' do

    it 'should pass simple link correctly' do
      link = LinkExtractor.parse_link('https://google.com', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should not overwrite domains with defined schema' do
      link = LinkExtractor.parse_link('https://google.com', 'google.com', 'http')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should add schema to double slash urls' do
      link = LinkExtractor.parse_link('//google.com', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should parse relative link' do
      link = LinkExtractor.parse_link('/news', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com/news')
    end

    it 'should parse external link correctly' do
      link = LinkExtractor.parse_link('//www.mediawiki.org/', 'google.com', 'http')

      expect(link.to_s).to eq('http://www.mediawiki.org/')
    end

    # because fragments are pointing to part of the page we should discard the fragment
    it 'should remove fragment from parsed links' do
      link = LinkExtractor.parse_link('#', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end
  end
end