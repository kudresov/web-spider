require 'neo4j'

class Resource
  include Neo4j::ActiveNode
  # TODO this doesn't guarantee 100% uniqueness will need to get a better strategy
  property :uri, type: String, constraint: :unique
  has_many :both, :resources, type: 'Resource'
end