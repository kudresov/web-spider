class Resource
  include Neo4j::ActiveNode
  property :uri, type: String
end