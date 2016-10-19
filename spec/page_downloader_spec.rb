require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../workers/page_downloader_worker.rb', __FILE__

describe 'Page Downloader' do

  def start_local_server(site_path)
    server_path = File.expand_path '../http_server.rb', __FILE__
    @web_server = Process.spawn(
        "#{server_path} #{site_path}",
        in: :close,
        out: :out,
        err: :out
    )

    # TODO need a better way to determine when serve is up and running
    sleep 7
  end

  before :each do
    Neo4j::Session.current._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
  end

  after :each do
    # Process.kill 'TERM', @web_server
  end

  describe 'downloading single page site' do

    before :all do
      site_path = File.expand_path '../web/single_page', __FILE__
      # start_local_server(site_path)
    end

    before :each do
      uri = Addressable::URI.parse('http://localhost:8000')
      PageDownloaderWorker.new.perform nil, uri
      PageDownloaderWorker.drain
    end

    it 'should create 2 node in db' do
      expect(Resource.all.count).to eq(2)
    end

    it 'should have 1 node if label image/jpeg' do
      expect(Resource.all.where(content_type: 'image/jpeg').count).to eq(1)
    end

    it 'should have 1 node if label text/html' do
      expect(Resource.all.where(content_type: 'text/html').count).to eq(1)
    end

    it 'should have a node with correct uri' do
      expect(Resource.first.uri).to eq('http://localhost:8000')
    end

    it 'should not have any relationships' do
      expect(Resource.first.resources.count).to eq(0)
    end
  end

  describe 'downloading 2 page site' do

    before :all do
      site_path = File.expand_path '../web/two_page_site', __FILE__
      # start_local_server(site_path)
    end

    before :each do
      uri = Addressable::URI.parse('http://localhost:8000')
      PageDownloaderWorker.new.perform nil, uri
      PageDownloaderWorker.drain
    end

    it 'should create 2 nodes in db' do
      expect(Resource.all.count).to eq(2)
    end
  end

  describe 'downloading 5 pages site' do

    before :all do
      site_path = File.expand_path '../web/simple_site', __FILE__
      # start_local_server(site_path)
    end

    before :each do
      uri = Addressable::URI.parse('http://localhost:8000')
      PageDownloaderWorker.new.perform nil, uri
      PageDownloaderWorker.drain
    end

    it 'should create 5 nodes in db' do
      expect(Resource.all.count).to eq(5)
    end

    it 'should have a link from about to home page' do
      page = Resource.find_by uri: 'http://localhost:8000/about.html'
      expect(page.resources.count).to eq(2)
    end
  end
end