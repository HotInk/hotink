class BlogDrop < Drop
  
  liquid_attributes :id, :title, :slug, :description
  
  alias_method :blog, :source # for readability
  
  def url
    "/blogs/#{blog.slug}"
  end
  
  def image_url
    blog.image.url(:small)
  end
  
  def entries
    @context.registers[:total_entries] = blog.entries.published.count
    blog.entries.published.paginate(:page => @context.registers[:page] || 1, :per_page => @context.registers[:per_page] || 20, :order => "published_at desc").collect{ |entry| EntryDrop.new(entry) }
  end
  
end
