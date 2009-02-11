class TagsController < ApplicationController
  before_filter :find_article
  
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

    respond_to do |format|
        flash[:notice] = 'Tag was successfully created.'
        format.js   { redirect_to(new_account_article_tag_url(@account, @article, :format=>:js))}
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
    @article.tags.delete(@tag)

    respond_to do |format|
      format.js   { redirect_to(new_account_article_tag_url(@account, @article, :format=>:js)) }
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
