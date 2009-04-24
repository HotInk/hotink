class ArticlesController < ApplicationController
  
  layout 'hotink'
  before_filter :require_user
  skip_before_filter :verify_authenticity_token
  
  
  # GET /articles
  # GET /articles.xml
  def index
    @search_query = params[:search]
    @articles = @account.articles.search( @search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => :date, :sort_mode => :desc, :include => [:authors, :mediafiles, :section])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @articles }
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
         @article.date = Time.now #Give it the current time, without saving.
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
