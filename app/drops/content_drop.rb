class ContentDrop < Drop
  
  alias_method :account, :source # for readability
  
  def before_method(method)
    if list = List.find_by_slug(method)
       ListDrop.new list
    else
      super(method)
    end 
  end
  
  def blogs
    Blog.all.collect{ |blog| BlogDrop.new(blog) }
  end
  
  def blog
   blogs = {}
    Blog.all.each do |blog|
      blogs[blog.slug] = BlogDrop.new(blog)
    end
    blogs
  end
  
  def categories
    account.categories.sections.all.collect{ |category| CategoryDrop.new(category) }
  end
  
  def category
    categories = {}
    account.categories.sections.each do |category|
      categories[category.name] = CategoryDrop.new(category)
    end
    categories
  end
  
  def lead_articles
    articles = account.lead_article_ids.collect{ |id| account.articles.published.find_by_id(id) }
    articles.compact.collect{ |article| ArticleDrop.new(article) }
  end
end

