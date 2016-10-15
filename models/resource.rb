class Resource
  include Neo4j::ActiveNode
  property :uri, type: String
  has_many :both, :resources, type: 'Resource'
end