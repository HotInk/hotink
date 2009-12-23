class ArticlesController < ApplicationController
  
  layout 'hotink'
  skip_before_filter :verify_authenticity_token
  
  # GET /articles
  # GET /articles.xml
  def index
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      
        # If the request if for secific ids, don't mess around, just return them
      if params[:ids]
        @articles = @account.articles.find_all_by_id(params[:ids], :include => [:authors, :mediafiles, :section])
        
        # check whether we're looking for section articles
      elsif params[:section_id]
        @category = @account.categories.find(params[:section_id])
        @articles = @category.articles.status_matches('published').published_at_in_past.by_published_at(:desc).paginate( :page => page, :per_page => per_page)
        
        # This is the primary way of finding tagged articles
      elsif params[:tagged_with]
        @articles = @account.articles.tagged_with(params[:tagged_with], :on => :tags).status_matches("published").by_published_at(:desc).paginate( :page=>(params[:page] || 1), :per_page => per_page )
      elsif params[:search]
        @search_query = params[:search]
        @articles = @account.articles.and_related_items.search( @search_query, :page => page, :per_page => per_page)
      else  
        @articles = @account.articles.and_related_items.status_matches('published').published_at_in_past.by_published_at(:desc).paginate( :page => page, :per_page => per_page)
        if page.to_i == 1
          @drafts = @account.articles.find( :all, :conditions => { :status => nil }, :include => [:authors, :mediafiles, :section] ).reject{ |draft| draft.created_at == draft.updated_at }
          @scheduled = @account.articles.and_related_items.status_matches('published').published_at_in_future.by_published_at(:desc).all
        end
      end
    
      respond_to do |format|
        format.html # index.html.erb
        format.js
        format.xml  { render :xml => @articles }
      end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = @account.articles.find(params[:id])

    expires_in 3.minutes, :private => false
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = @account.articles.build    
    
    #Check to see if the last article created is exists and is blank.
    #If so, redate it and serve it up instead of a new article, to prevent
    #the data from becoming cluttered with abandoned articles.
    #
    #If the last article was legit, save the fresh article so it can have relationships 
    if last_article = @account.articles.find(:last)
      if last_article.created_at == last_article.updated_at
         @article = last_article
      else
        @article.save
      end
    else
      @article.save
    end
    
    respond_to do |format|
      flash[:notice] = "New article"
      format.html { redirect_to edit_account_article_path(@account, @article) }
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = @account.articles.find(params[:id])
    
    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = @account.articles.build(params[:article])
    
    respond_to do |format|
      if @article.save
        format.html { redirect_to(account_article_path(@account, @article)) }
        format.xml  { render :xml => @article, :status => :created, :location => [@account, @article] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = @account.articles.find(params[:id])
    
    # Only touch published status if status is passed
    if params[:article][:status]      
      # Should we schedule publishing on a custom date or immediately?
      # Rely on a "schedule" parameter to determine which.
      if params[:article][:schedule] 
        schedule = params[:article].delete(:schedule)
        @article.publish(params[:article].delete(:status), Time.local(schedule[:year].to_i, schedule[:month].to_i, schedule[:day].to_i, schedule[:hour].to_i, schedule[:minute].to_i) )
      else
        @article.publish(params[:article].delete(:status))
      end
    end
        
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = "Article saved"
        @article = @account.articles.find(params[:id])
        @article.categories << @article.section unless @article.categories.member?(@article.section) || @article.section.nil? #Create sorting for current section, if necessary        
        format.js
        format.html { redirect_to(edit_account_article_path(@account, @article)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = @account.articles.find(params[:id])
    @article.destroy

    respond_to do |format|
      flash[:notice] = "Article trashed"
      format.html { redirect_to(account_articles_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
