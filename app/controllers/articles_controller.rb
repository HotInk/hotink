class ArticlesController < ApplicationController
  include DocumentsHelper
  
  layout 'hotink'
  skip_before_filter :verify_authenticity_token
  
  # GET /articles
  # GET /articles.xml
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    if page.to_i == 1
      @awaiting_attention = @account.articles.awaiting_attention.all
    end
    @articles = @account.articles.paginate(:page => page, :per_page => per_page, :order => 'status, published_at desc, updated_at desc', :include => [:authors, :mediafiles, :section])
  
    respond_to do |format|
      format.html
    end
  end
  
  # GET /articles/search
  def search
    if params[:q]
      page = params[:page] || 1
      per_page = params[:per_page] || 10  
      @search_query = params[:q]
      @articles = @account.articles.search( @search_query, :page => page, :per_page => per_page, :include => [:authors, :mediafiles, :section])
    else
      @articles = []
    end
  end

  # GET /articles/1
  def show
    @article = @account.articles.find(params[:id])
  end

  # GET /articles/new
  def new
    @article = @account.articles.create 
    @article.owner = current_user
    
    respond_to do |format|
      flash[:notice] = "New article"
      format.html { redirect_to edit_account_article_path(@account, @article) }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = @account.articles.find(params[:id])
    
    permit @article.is_editable_by do
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  # PUT /articles/1
  def update
    @article = @account.articles.find(params[:id])
    
    publish_time = params[:article].delete(:schedule)
    
    permit @article.is_editable_by do
      # Only touch published status if status is passed
      if params[:article][:status]=="Published"
        if permit?("(manager of account) or admin")
          @article.publish extract_time(publish_time)
        end
      elsif params[:article][:status]=="Awaiting attention"
        @article.sign_off(current_user)
      elsif params[:article][:status]==""
        @article.unpublish
      end

      if params[:article][:revoke_sign_off]
        params[:article].delete(:revoke_sign_off)
        @article.revoke_sign_off(current_user)
        @article.save
      end
        
      respond_to do |format|
        if @article.update_attributes({'category_ids' => []}.merge(params[:article]))
          flash[:notice] = "Article saved"
          format.html { redirect_to(edit_account_article_path(@account, @article)) }
        else
          format.html { render :action => "edit", :status => :bad_request }
        end
      end
      
    end
  end

  # DELETE /articles/1
  def destroy
    @article = @account.articles.find(params[:id])
    permit @article.is_editable_by do
      @article.destroy
    
      flash[:notice] = "Article trashed"
      redirect_to(account_articles_url(@account))
    end
  end
end
