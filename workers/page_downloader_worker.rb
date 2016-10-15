require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require File.expand_path '../../models/resource.rb', __FILE__

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end

class PageDownloaderWorker
  include Sidekiq::Worker
  def perform(parent_uri, uri)
    Resource.create uri: uri
  end
end