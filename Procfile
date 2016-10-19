web: bundle exec rackup config.ru -p $PORT
worker: sidekiq -r ./workers/page_downloader_worker.rb -c 10