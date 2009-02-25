class ArticlesController < ApplicationController
  
  # GET /articles
  # GET /articles.xml
  def index
    @articles = @account.articles.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = @account.articles.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    #Check to see if the last article created is blank. If so,
    #redate it and serve it up instead of a new article, to prevent
    #the data from becoming cluttered with abandoned articles. 
    if last_article = @account.articles.find(:first, :order=>"date ASC")
      if last_article.created_at == last_article.updated_at
         @article = last_article
      else
        @article = Article.new
      end
    else
      @article = Article.new
    end
    @article.date = Time.now
    @article.account = @account
    @article.save
    
    respond_to do |format|
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
    @article = Article.new(params[:article])
    @article.account = @account
    
    respond_to do |format|
      if @article.save
        format.html { redirect_to(account_article_path(@account, @article)) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
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
        @article = @account.articles.find(params[:id])
        #Create sorting for current section, if necessary
        @article.categories << @article.section unless @article.categories.member?(@article.section)
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
      format.html { redirect_to(account_articles_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
