class ArticlesController < ApplicationController
  
  layout 'hotink'
  skip_before_filter :verify_authenticity_token
  
  # GET /articles
  # GET /articles.xml
  def index
      page = params[:page] || 1
      per_page = params[:per_page] || 20
      
      if params[:search]
        @search_query = params[:search]
        @articles = @account.articles.search( @search_query, :page => page, :per_page => per_page, :include => [:authors, :mediafiles, :section])
      else  
        if page.to_i == 1
          @drafts = @account.articles.drafts.and_related_items
          @scheduled = @account.articles.scheduled.and_related_items.by_published_at(:desc)
          @awaiting_attention = @account.articles.awaiting_attention.all
        end
        @articles = @account.articles.published.by_published_at(:desc).paginate( :page => page, :per_page => per_page, :include => [:authors, :mediafiles, :section])
      end
    
      respond_to do |format|
        format.html
        format.js
      end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = @account.articles.find(params[:id])
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
        format.html # new.html.erb
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = @account.articles.find(params[:id])
    
    permit @article.is_editable_by do
      
      # Only touch published status if status is passed
      if params[:article][:status]=="Published"
        
        if permit?("(manager of account) or admin")
          # Should we schedule publishing on a custom date or immediately?
          # Rely on a "schedule" parameter to determine which.
          if params[:article][:schedule] 
            schedule = params[:article].delete(:schedule)
            @article.schedule(Time.local(schedule[:year].to_i, schedule[:month].to_i, schedule[:day].to_i, schedule[:hour].to_i, schedule[:minute].to_i))
          else
            @article.publish
          end
        end
        
      elsif params[:article][:status]=="Awaiting attention"
        @article.sign_off(current_user)
      elsif params[:article][:status]==""
        params[:article][:status]=nil #To make sure an article is upublished properly
      end
      
      if params[:article][:revoke_sign_off]
        params[:article].delete(:revoke_sign_off)
        @article.revoke_sign_off(current_user)
        @article.save
      end
        
      respond_to do |format|
        if @article.update_attributes(params[:article])
          flash[:notice] = "Article saved"
          @article = @account.articles.find(params[:id])
          @article.categories << @article.section unless @article.categories.member?(@article.section) || @article.section.nil? #Create sorting for current section, if necessary        
          format.js
          format.html { redirect_to(edit_account_article_path(@account, @article)) }
        else
          format.html { render :action => "edit" }
        end
      end
      
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = @account.articles.find(params[:id])
    permit @article.is_editable_by do
      @article.destroy
    
      flash[:notice] = "Article trashed"
      redirect_to(account_articles_url(@account))
    end
  end
end
