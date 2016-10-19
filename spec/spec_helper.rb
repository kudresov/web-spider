require 'rack/test'
require 'rspec'
require 'neo4j'
require 'addressable/uri'
require 'sidekiq/testing'

ENV['RACK_ENV'] = 'test'
# neo4j_url = ENV['NEO4J_URL'] || 'http://localhost:7474'
# neo4j_username = ENV['NEO4J_USERNAME'] || 'neo4j'
# neo4j_password = ENV['NEO4J_PASSWORD'] || 'admin'
#
# session = Neo4j::Session.open(:server_db, neo4j_url, basic_auth: {username: neo4j_username, password: neo4j_password})
Sidekiq::Testing.fake!

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }