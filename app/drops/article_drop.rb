class ArticleDrop < Drop
  include TextFilters
  
  alias_method :article, :source # for readability

  liquid_attributes :id, :title, :bodytext, :word_count
   
  
  def url
    "/accounts/#{article.account.id}/articles/#{article.id}"
  end
  
  def excerpt
    if article.summary.blank?
      shorten article.bodytext, 120
    else
      article.summary
    end
  end
  
  def section
    if article.section.nil?
      nil
    else
      article.section.name
    end
  end
   
  # Article date methods
   def published_at
     if article.published?
       article.published_at.to_s(:standard).gsub(' ', '&nbsp;')
     elsif article.scheduled?
       "Will be available " + article.published_at.to_s(:standard).gsub(' ', '&nbsp;')
     elsif article.draft?
       "Draft"
     end
   end

   def published_at_detailed
     if article.published?
       article.published_at.to_datetime
     elsif article.scheduled?
       "Will be available " + article.published_at.to_s(:long)
     elsif article.draft?
       "Draft"
     end
   end
  
   def updated_at
     article.updated_at.to_s(:standard).gsub(' ', '&nbsp;')
   end

   def updated_at_detailed
     article.updated_at.to_datetime
   end
   
   # Authors
   def authors
     article.authors
   end

   def authors_list
     if article.authors_list.blank?
       nil
     else
       article.authors_list
     end
   end
   
   def subtitle
     if article.subtitle.blank?
       nil
     else
       article.subtitle
     end
   end
   
   # Categories
   def categories
     article.categories.collect{ |category| CategoryDrop.new(category) }
   end
   
   # Media
   def images
     article.images.collect do |i|
       waxing = Waxing.find_by_document_id_and_mediafile_id(article.id, i.id) 
       MediafileDrop.new(i, :caption => waxing.caption) 
     end
   end

   def has_image?
     if article.images.detect{|i| i }
       return true
     else
       return false
     end
   end
   
   def has_vertical_image?
     if article.images.detect { |image| image.height.to_i > image.width.to_i }
       return true
     else
       return false
     end
   end
   
   def first_vertical_image
     if image = article.images.detect { |image| image.height.to_i > image.width.to_i }
       MediafileDrop.new(image)
     else
       nil
     end
   end

   def has_horizontal_image?
     if article.images.detect { |image| image.height.to_i <= image.width.to_i }
       return true
     else
       return false
     end
   end

   def first_horizontal_image
    if image = article.images.detect { |image| image.height.to_i <= image.width.to_i }
      MediafileDrop.new(image)
    else
      nil
    end
   end
   
   # Comments
   
   def comments
     article.comments.find(:all, :order => "created_at asc").collect{|comment| CommentDrop.new(comment) }
   end
   
   def has_comments?
     article.comments.count > 0
   end
   
   def comment_count
     article.comments.count
   end
   
   def comments_locked
     article.comments_locked?
   end

   def comments_enabled
     article.comments_enabled?
   end
end
