class SiteDrop < Drop
  
  alias_method :account, :source # for readability
  
  def blogs_url
    if @context.registers[:design].current_design?
      "#{account.site_url}/blogs"
    else
      "#{account.site_url}/blogs?design_id=#{@context.registers[:design].id}"
    end
  end
  
  def front_page_url
    if @context.registers[:design].current_design?
      "#{account.site_url}/"
    else
      "#{account.site_url}/?design_id=#{@context.registers[:design].id}"
    end
  end
  
  def feed_url
    "#{account.site_url}/feed.xml"
  end
  
  def issues_url
    if @context.registers[:design].current_design?
      "#{account.site_url}/issues"
    else
      "#{account.site_url}/issues?design_id=#{@context.registers[:design].id}"
    end
  end
  
  def search_url
    if @context.registers[:design].current_design?
      "#{account.site_url}/search"
    else
      "#{account.site_url}/search?design_id=#{@context.registers[:design].id}"
    end
  end
  
  def per_page
    @context.registers[:per_page]
  end
  
  def current_page
    @context.registers[:page]
  end
end
