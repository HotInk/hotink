class ListDrop < Drop
  liquid_attributes :id, :name, :slug, :description
  
  alias_method :list, :source # for readability
  
  def articles
    list.documents.published.collect{ |article| ArticleDrop.new(article) }
  end
end