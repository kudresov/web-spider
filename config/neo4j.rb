require 'neo4j'
require 'neo4j-core'

neo_url = ENV['NEO4J_URL'] || 'http://neo4j:admin@localhost:7474'
Neo4j::Session.open(:server_db, neo_url)