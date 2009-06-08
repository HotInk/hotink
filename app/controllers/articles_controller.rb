class ArticlesController < ApplicationController
  
  layout 'hotink'
  skip_before_filter :verify_authenticity_token

  
  # GET /articles
  # GET /articles.xml
  def index
    
    # This split ona blank search query is important, even though thinking-sphinx will return ordered search
    # results on a blank query. Sphinx delta index isn't ordered with the regular index, so the ordering just
    # doesn't work.
    if params[:search].blank?
      
      conditions = { :status => "published" }
      
      # check whether we're looking for section articles
      unless params[:section_id].blank?
        conditions[:section_id] = params[:section_id]
      end
  
      # TODO: do something similar for issues      
      @articles = @account.articles.paginate( :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => "published_at DESC", :include => [:authors, :mediafiles, :section], :conditions => conditions)
      @drafts = @account.articles.find( :all, :conditions => { :status => nil }, :include => [:authors, :mediafiles, :section] ) unless params[:page]
    else  
      @search_query = params[:search]
      @articles = @account.articles.search( @search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :include => [:authors, :mediafiles, :section])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @articles.select{ |article| article.published_at < Time.now } }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = @account.articles.find(params[:id], :include=>:authors)

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
