class CategoryDrop < Drop
  
  alias_method :category, :source # for readability
  
  liquid_attributes :name, :slug, :path, :parent_id
  
  def url
    "/categories#{category.path}"
  end
  
  def subcategories
    category.children.collect{ |child| CategoryDrop.new(child) }
  end
  
  def subcategory
    subcategories = {}
    category.children.each do |category|
      subcategories[category.name] = CategoryDrop.new(category)
    end
    subcategories
  end
    
  def articles
    category.articles.published.find(:all, :order => "published_at desc", :limit => 20).collect{ |a| ArticleDrop.new(a)  }
  end
  
  def has_articles?
    if category.articles.published.detect{|i| i }
      return true
    else
      return false
    end
  end
  
  
end
