class EntryDrop < ArticleDrop
  alias_method :entry, :article # for readability
  
  def blog
    BlogDrop.new(entry.blog)
  end
end