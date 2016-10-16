require './app'
require 'sidekiq'
require 'sidekiq/web'

run Sinatra::Application
run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)