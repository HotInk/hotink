class TagsController < ApplicationController
  before_filter :find_article, :find_mediafile, :find_entry
  
  # GET /tags/new.js
  def new
    respond_to do |format|
      format.js
    end
  end

  # POST /tags
  def create
    #Only create tags if a list is sent with the request
    if params[:new_tag_list] then   
      #Besure that this submission isn't just the default input value in from standard tag form
      unless params[:new_tag_list] =~ /Add tags here/ then      
        #Check to see what sort of media we're tagging
        if @article
          tagged = @article
        elsif @entry
          tagged = @entry
        elsif @mediafile
          tagged = @mediafile
        end
          
        #Behave differently depending on whether this article has any existing tags
        if tagged.tag_list
          tagged.tag_list = tagged.tag_list.to_s + ", #{params[:new_tag_list]}"
        else
          tagged.tag_list = params[:new_tag_list]
        end
      end
        #Save article to commit tags
        tagged.save 
    end
    
    respond_to do |format|
        if tagged.is_a? Article
          format.js   { redirect_to(new_account_article_tag_url(@account, @article, :format=>:js))}
        elsif tagged.is_a? Entry
          format.js   { redirect_to(new_account_blog_entry_tag_url(@account, @blog, @entry, :format=>:js))}
        elsif tagged.is_a? Mediafile
          format.js   { redirect_to(new_account_mediafile_tag_url(@account, @mediafile, :format=>:js))}
        end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    
    # Find out which taggable we're working with
    taggable = (@article || @mediafile || @entry)
    taggable.tags.delete(@tag)

    respond_to do |format|
      if @article
        format.js   { redirect_to(new_account_article_tag_url(@account, @article, :format=>:js)) }
      elsif @mediafile
        format.js   { redirect_to(new_account_mediafile_tag_url(@account, @mediafile, :format=>:js)) }
      elsif @entry
        format.js   { redirect_to(new_account_blog_entry_tag_url(@account, @blog, @entry, :format=>:js)) }
      end
    end
  end  
 
end
