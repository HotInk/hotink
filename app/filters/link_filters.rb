module LinkFilters
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  
  def link_to_article(arg1, arg2=nil)
    if arg1.is_a?(ArticleDrop)
      article = arg1
      title = arg2 || article.title
    elsif arg1.is_a?(String)
      title = arg1
      article = arg2
      return "<!-- No article to link to --> #{title}" unless article.is_a?(ArticleDrop)
    end
    if @context.registers[:design].current_design?
      url = "/articles/#{article.id}"
    else
      url = "/articles/#{article.id}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end
  
  def link_to_blog(arg1, arg2=nil)
    if arg1.is_a?(BlogDrop)
      blog = arg1
      title = arg2 || blog.title
    elsif arg1.is_a?(String)
      title = arg1
      blog = arg2
      return "<!-- No blog to link to --> #{title}" unless blog.is_a?(BlogDrop)
    end
    if @context.registers[:design].current_design?
      url = "/blogs/#{blog.slug}"
    else
      url = "/blogs/#{blog.slug}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end
  
  def link_to_entry(arg1, arg2=nil)
    if arg1.is_a?(EntryDrop)
      entry = arg1
      title = arg2 || entry.title
    elsif arg1.is_a?(String)
      title = arg1
      entry = arg2
      return "<!-- No entry to link to --> #{title}" unless entry.is_a?(EntryDrop)
    end
    if @context.registers[:design].current_design?
      url = "/blogs/#{entry.blog.slug}/#{entry.id}"
    else
      url = "/blogs/#{entry.blog.slug}/#{entry.id}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end
  
  def link_to_page(arg1, arg2=nil)
    if arg1.is_a?(PageDrop)
      page = arg1
      title = arg2 || page.name
    elsif arg1.is_a?(String)
      title = arg1
      page = arg2
      return "<!-- No page to link to --> #{title}" unless page.is_a?(PageDrop)
    end
    if @context.registers[:design].current_design?
      url = "/pages#{page.url}"
    else
      url = "/pages#{page.url}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end 
  
  def link_to_category(arg1, arg2=nil)
    if arg1.is_a?(CategoryDrop)
      category = arg1
      title = arg2 || category.name
    elsif arg1.is_a?(String)
      title = arg1
      category = arg2
      return "<!-- No category to link to --> #{title}" unless category.is_a?(CategoryDrop)
    end
    if @context.registers[:design].current_design?
      url = "/categories#{category.path}"
    else
      url = "/categories#{category.path}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end
  
  def link_to_issue(arg1, arg2=nil)
    if arg1.is_a?(IssueDrop)
      issue = arg1
      title = arg2 || issue.date.strftime(%"%B %e, %Y")
    elsif arg1.is_a?(String)
      title = arg1
      issue = arg2
      return "<!-- No issue to link to --> #{title}" unless issue.is_a?(IssueDrop)
    end
    if @context.registers[:design].current_design?
      url = "/issues/#{issue.id}"
    else
      url = "/issues/#{issue.id}?design_id=#{@context.registers[:design].id}"
    end
    link_to title, url  
  end 
end
