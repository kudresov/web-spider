require 'neo4j'

class Resource
  include Neo4j::ActiveNode
  # TODO this doesn't guarantee 100% uniqueness, especially when running on multiple threads. Will need to get a better strategy
  property :uri, type: String, constraint: :unique
  property :content_type, type: String
  has_many :both, :resources, type: 'LINKS_TO'

  def is_crawlable?
    # TODO need a better way to determine if page is crawlable
    content_type.include? 'text/html'
  end
end