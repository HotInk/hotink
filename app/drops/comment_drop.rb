class CommentDrop < Drop
  alias_method :comment, :source # for readability
  
  liquid_attributes :name, :email, :ip_address, :body
  
  def date
    comment.created_at.to_datetime
  end
end