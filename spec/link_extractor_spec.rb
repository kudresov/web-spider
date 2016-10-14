require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../link_extractor.rb', __FILE__

describe 'Link extractor' do

  describe 'get_raw_links' do

    test_data = [
        {page: 'one_link.html', expected_links_count: 1},
        {page: 'three_links.html', expected_links_count: 3},
        {page: 'malformed_body.html', expected_links_count: 1},
        {page: 'relative_links.html', expected_links_count: 5},
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
end