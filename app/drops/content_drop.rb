class ContentDrop < Drop
  
  alias_method :account, :source # for readability
  
  def before_method(method)
    if list = account.lists.find_by_slug(method)
       ListDrop.new list
    else
      super(method)
    end 
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
  
  def latest_issue
    IssueDrop.new(account.issues.find(:first, :order => "date desc"))
  end
  
  def issues
    @context.registers[:total_entries] = account.issues.count
    account.issues.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 5, :order => "date desc").collect{ |issue| IssueDrop.new(issue) }
  end
  
  def blogs
    account.blogs.collect{ |blog| BlogDrop.new(blog) }
  end
  
  def blog
   blogs = {}
    account.blogs.each do |blog|
      blogs[blog.slug] = BlogDrop.new(blog)
    end
    blogs
  end
  
  def lead_articles
    article_ids = options[:preview_lead_article_ids] || account.lead_article_ids
    articles = article_ids.collect{ |id| account.articles.published.find_by_id(id) }
    articles.compact.collect{ |article| ArticleDrop.new(article) }
  end
end

