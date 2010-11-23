class ArticleDrop < Drop
  include TextFilters
  include LinkFilters
  
  alias_method :article, :source # for readability

  liquid_attributes :id, :title, :bodytext, :word_count, :network_article?
   
  def url
    "/articles/#{article.id}"
  end

  def tags
    article.tag_list
  end
  
  def tags_list
    article.tag_list.join(', ')
  end
  
  def tags_list_with_links  
    case article.tag_list.length
     when 0
       return nil
     when 1
       return article.tag_list.first.blank? ? "" : link_to_tag(article.tag_list.first)
     else
      tags_list = article.tag_list.collect{ |t| link_to_tag(t) }
      tags_list.join(', ')
    end
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
   
   # Returns list of article's author names as a readable list, separated by commas and the word "and".
   def authors_list_with_links
      case article.authors.length
      when 0
        return nil
      when 1
        return article.authors.first.blank? ? "" : link_to_author(article.authors.first)
      when 2
       #Catch cases where the second author is actually an editorial title, this is weirdly common.
       if article.authors.second.name =~ / editor| Editor| writer| Writer|Columnist/
         return link_to_author(article.authors.first)+ " - " + article.authors.second.name
       else
         return link_to_author(article.authors.first) + " and " + link_to_author(article.authors.second)
       end
      else
       list = String.new
       (0..(article.authors.length - 3)).each{ |i| list += link_to_author(article.authors[i]) + ", " }
       list += link_to_author(article.authors[article.authors.length-2]) + " and " + link_to_author(article.authors[article.authors.length-1]) # last two authors get special formatting
       return list
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
   
   def audiofiles
     article.audiofiles.collect do |i|
       waxing = Waxing.find_by_document_id_and_mediafile_id(article.id, i.id) 
       MediafileDrop.new(i, :caption => waxing.caption) 
     end
   end

   def has_audiofile?
     if article.audiofiles.detect{|i| i }
       return true
     else
       return false
     end
   end
   
   # Network
   
   def network_original
     if original = article.network_original
       original
     end
   end
   
   def network_original_account_name
     if original = article.network_original
       original.account.formal_name
     end
   end
   
   def network_original_url
     if original = article.network_original
       host = original.account.reload.site_url.blank? ? "http://#{original.account.name}.hotink.net" : original.account.site_url
       "#{host}/articles/#{original.id}"
     end
   end
   
   def network_original_account_url
     if article.network_original && !article.network_original.account.site_url.blank?
       article.network_original.account.site_url
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
