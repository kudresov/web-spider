require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { db: 1, size: 5}
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1, size: 12}
end