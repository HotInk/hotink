class ArticleDrop < Drop
  include TextFilters
  
  alias_method :article, :source # for readability

  liquid_attributes :id, :title, :subtitle, :bodytext, :word_count
   
  
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
       article.published_at.to_s(:long)
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
     article.updated_at.to_s(:long)
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
end
