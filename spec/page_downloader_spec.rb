require File.expand_path '../spec_helper.rb', __FILE__
# require File.expand_path '../../workers/page_downloader_worker.rb', __FILE__

describe 'Page Downloader' do
  before :all do
    site_path = File.expand_path '../web/simple_site', __FILE__
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

  after :all do
    Process.kill 'TERM', @web_server
  end

  it "should do" do
    puts 'started'
  end

end