class TagsController < ApplicationController
  before_filter :find_article, :find_mediafile, :find_entry
  
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
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
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
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
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end  
 
end
