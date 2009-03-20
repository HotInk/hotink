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
    @article = @account.articles.build    
    @article.date = Time.now
    
    #Check to see if the last article created is exitsts, and is blank.
    #If so, redate it and serve it up instead of a new article, to prevent
    #the data from becoming cluttered with abandoned articles.
    #
    #If the last article was legit, save the fresh article so it can have relationships 
    if last_article = @account.articles.find(:last)
      if last_article.created_at == last_article.updated_at
         @article = last_article
         @article.date = Time.now
      else
        @article.save
      end
    else
      @article.save
    end
    
    #Update the date

    
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
    @article = @account.articles.build(params[:article])
    
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
