module DocumentsHelper
  
  #Extract time from parameter hash of appropriate strings
  def extract_time(time_hash)
    return nil if time_hash.nil?
    Time.local(time_hash[:year].to_i, time_hash[:month].to_i, time_hash[:day].to_i, time_hash[:hour].to_i, time_hash[:minute].to_i)
  end
  
  # Returns a short phrase indicating a document's publication status
  def publication_status_for(document)
    if document.draft?
      "Draft"
    elsif document.scheduled?
      "Scheduled"
    elsif document.is_a?(Article)&&document.awaiting_attention?
      "Signed off by <strong>#{ document.sign_offs.last.user == current_user ? "<em>you</em>" :  document.sign_offs.last.user.name }</strong>, <strong>#{document.sign_offs.last.created_at.to_s(:date)}</strong> at <strong>#{document.sign_offs.last.created_at.to_s(:time)}</strong>"
    end
  end
  
  def document_url_for_user(document, user)
    if document.owner==user||user.has_role?("manager", document.account)||user.has_role?("admin")
      if document.is_a? Entry
        edit_account_blog_entry_url(document.account, document.blog, document)
      elsif document.is_a? Article
        edit_account_article_url(document.account, document)
      end
    else
      if document.is_a? Entry
        account_blog_entry_url(document.account, document.blog, document)
      elsif document.is_a? Article
        account_article_url(document.account, document)
      end
    end
  end
end