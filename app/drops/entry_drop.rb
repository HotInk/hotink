class EntryDrop < ArticleDrop
  alias_method :entry, :article # for readability
  
  def blog
    BlogDrop.new(entry.blog)
  end
  
  def url
    "/blogs/#{entry.blog.slug}/#{entry.id}"
  end
end