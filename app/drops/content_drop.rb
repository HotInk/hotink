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
  
  def pages
    account.pages.main_pages.all.collect{ |page| PageDrop.new(page) }
  end
  
  def page
    pages = {}
    account.pages.each do |page|
      pages[page.url] = PageDrop.new(page)
    end
    pages
  end
  
  def latest_issue
    IssueDrop.new(account.issues.find(:first, :order => "date desc"))
  end
  
  def issues
    @context.registers[:total_entries] = account.issues.count
    account.issues.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 20, :order => "date desc").collect{ |issue| IssueDrop.new(issue) }
  end
  
  def latest_article
    ArticleDrop.new(account.articles.published.find(:first, :order => "published_at desc"))
  end
  
  def articles
    @context.registers[:total_entries] = account.articles.published.count
    account.articles.published.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 20, :order => "published_at desc").collect{ |article| ArticleDrop.new(article) }
  end
  
  def entries
    @context.registers[:total_entries] = account.entries.published.count
    account.entries.published.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 20, :order => "published_at desc").collect{ |entry| EntryDrop.new(entry) }
  end
  
  def latest_entry
    EntryDrop.new(account.entries.published.find(:first, :order => "published_at desc"))
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
    article_ids = options[:preview_lead_article_ids] || account.lead_article_ids || []
    articles = article_ids.collect{ |id| account.articles.published.find_by_id(id) }
    articles.compact.collect{ |article| ArticleDrop.new(article) }
  end
end

