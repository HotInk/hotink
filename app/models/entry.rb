class Entry < Document
  belongs_to :blog
    
  def is_editable_by
    if published? && published_at < 3.weeks.ago
        "(editor of blog) or (manager of account) or admin"
    else
      "(owner of entry) or (editor of blog) or (manager of account) or admin"
    end
  end

end
