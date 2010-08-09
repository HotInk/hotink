class ArticlesController < ApplicationController
  include DocumentsHelper
  
  layout 'hotink'
  skip_before_filter :verify_authenticity_token
  
  # GET /articles
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
    if params[:q].blank?
      @articles = []
    else
      page = params[:page] || 1
      per_page = params[:per_page] || 10  
      @search_query = params[:q]
      @articles = @account.articles.published_or_scheduled.search(@search_query, :page => page, :per_page => per_page, :order => "published_at desc", :include => [:authors, :mediafiles, :section])
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
      format.html { redirect_to edit_article_path(@article) }
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
  
  # GET /articles/edit_multiple
  def edit_multiple
    @update_action_name = params[:update_action_name]
    @articles = @account.articles.find(params[:article_ids])
    respond_to do |format|
       format.html
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
      elsif params[:article][:status]=="Revoke sign off"
        params[:article].delete(:status)
        @article.revoke_sign_off(current_user)
      elsif params[:article][:status]==""
        @article.unpublish
      end
        
      respond_to do |format|
        if @article.update_attributes({'category_ids' => []}.merge(params[:article]))
          flash[:notice] = "Article saved"
          format.html { redirect_to(edit_article_path(@article)) }
        else
          format.html { render :action => "edit", :status => :bad_request }
        end
      end
      
    end
  end
  
  # GET /articles/edit_multiple
  def update_multiple
    @articles = @account.articles.find(params[:article_ids])
    @update_action_name = params[:update_action_name]
    @articles.each do|article|
      action_class = (@update_action_name + "_action").classify.constantize
      action = action_class.new(article, params[:options])
      action.execute
    end
    
    if @update_action_name=="delete"
      flash[:notice] = "Articles deleted."
    else
      flash[:notice] = "Articles updated."
    end
    
    redirect_to articles_url
  end

  # GET /articles/comments
  def comments
    @article = @account.articles.find(params[:article_id])
    @comments = @article.comments.find(:all, :order => "created_at DESC")
    
    render :action => :comments, :layout => false
  end

  # GET /articles/1/lock_comments
  def lock_comments
    @article = @account.articles.find(params[:id])
    @article.lock_comments
  end
  
  # GET /articles/1/disable_comments  
  def disable_comments
    @article = @account.articles.find(params[:id])
    @article.disable_comments
  end
  
  # GET /articles/1/enable_comments
  def enable_comments
    @article = @account.articles.find(params[:id])
    @article.enable_comments
  end


  # DELETE /articles/1
  def destroy
    @article = @account.articles.find(params[:id])
    permit @article.is_editable_by do
      @article.destroy
    
      flash[:notice] = "Article trashed"
      redirect_to(articles_url)
    end
  end
end
