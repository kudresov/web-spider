require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__

describe 'Link extractor' do

  describe 'Get raw links' do

    it 'should give one link for site with one simple link' do
      # arrange
      one_link_html_path = File.expand_path('../web/one_link.html', __FILE__)
      one_link_html = File.read(one_link_html_path)
      link_extractor = LinkExtractor.new(one_link_html)
      expected_link_count = 1

      # act
      raw_links = link_extractor.get_raw_links

      # assert
      expect(raw_links.count).to eq(expected_link_count)
    end
  end
end