class CommentDrop < Drop
  alias_method :comment, :source # for readability
  
  liquid_attributes :name, :email, :ip_address, :body
  
  def date
    comment.created_at.to_datetime
  end
  
  def url
    if comment.document.is_a? Entry
      "/blogs/#{comment.document.blog.slug}/#{comment.document.id}#comment-#{comment.id}"
    elsif comment.document.is_a? Article
      "/articles/#{comment.document.id}#comment-#{comment.id}"
    end
  end
end