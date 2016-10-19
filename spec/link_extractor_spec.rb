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

  describe 'get_crawlable_domain_links' do
    it 'should give one link for domain' do
      # arrange
      html_path = File.expand_path('../web/one_link.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('google.com', 'https')

      # assert
      expect(domain_links.count).to eq(1)
    end

    xit 'should extract links with no slash and base define correctly' do

    end

    it 'should give 2 links for three links page' do
      # arrange
      html_path = File.expand_path('../web/three_links.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('google.com', 'https')

      # assert
      expect(domain_links.count).to eq(2)
    end

    it 'should give right amount of links for a page with duplicates' do
      # arrange
      html_path = File.expand_path('../web/duplicate_links.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('google.com', 'https')

      # assert
      expect(domain_links.count).to eq(2)
    end

    it 'should have correct number of links for wikipedia homepage' do
      # arrange
      html_path = File.expand_path('../web/wikipedia.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('wikipedia.org', 'https')

      # assert
      expect(domain_links.count).to eq(230)
    end

    it 'should have a correct number of links for page with 3 images' do
      # arrange
      html_path = File.expand_path('../web/image_page.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('localhost', 'http')

      # assert
      expect(domain_links.count).to eq(2)
    end

    it 'should have a correct number of css files' do
      # arrange
      html_path = File.expand_path('../web/style_page.html', __FILE__)
      html = File.read(html_path)
      link_extractor = LinkExtractor.new(html)

      # act
      domain_links = link_extractor.get_crawlable_domain_links('localhost', 'http')

      # assert
      expect(domain_links.count).to eq(1)
    end
  end

  describe 'build_crawlable_link' do

    it 'should build simple link correctly' do
      link = LinkExtractor.build_crawlable_link('https://google.com', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should build simple link without scheme correctly' do
      link = LinkExtractor.build_crawlable_link('google.com', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should not overwrite domains with defined schema' do
      link = LinkExtractor.build_crawlable_link('https://google.com', 'google.com', 'http')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should add schema to double slash urls' do
      link = LinkExtractor.build_crawlable_link('//google.com', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should parse relative link' do
      link = LinkExtractor.build_crawlable_link('/news', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com/news')
    end

    it 'should parse external link correctly' do
      link = LinkExtractor.build_crawlable_link('//www.mediawiki.org/', 'google.com', 'http')

      expect(link.to_s).to eq('http://www.mediawiki.org')
    end

    # because fragments are pointing to part of the page we should discard the fragment
    it 'should remove empty fragment from parsed links' do
      link = LinkExtractor.build_crawlable_link('#', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should remove fragment from parsed links' do
      link = LinkExtractor.build_crawlable_link('#about', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end

    it 'should parse a no trailing slash link page' do
      # TODO implement functionality to support non compliant links
      link = LinkExtractor.build_crawlable_link('about.html', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com/about.html')
    end

    it 'should parse slash only as domain without trailing slash' do
      link = LinkExtractor.build_crawlable_link('/', 'google.com', 'https')

      expect(link.to_s).to eq('https://google.com')
    end
  end
end