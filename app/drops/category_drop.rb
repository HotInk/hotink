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
    
  def parent
    if parent = category.parent
      CategoryDrop.new(category.parent)
    end
  end  
  
  def articles
    category.articles.published.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 20, :order => "published_at desc").collect{ |a| ArticleDrop.new(a)  }
  end
  
  def has_articles?
    if category.articles.published.detect{|i| i }
      return true
    else
      return false
    end
  end
  
  
end
