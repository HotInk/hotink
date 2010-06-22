class Entry < Document
  belongs_to :blog
    
  def is_editable_by
    if published? && published_at < 3.weeks.ago
        "(editor of blog) or (manager of account) or admin"
    else
      "(owner of entry) or (editor of blog) or (manager of account) or admin"
    end
  end
  
  def is_publishable_by
    "(owner of entry) or (manager of account) or (editor of blog) or admin"
  end

end
