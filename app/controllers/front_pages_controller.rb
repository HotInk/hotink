class FrontPagesController < ApplicationController
  
  layout 'hotink'
  
  permit "admin"
  
  def edit
    page = params[:page] || 1
    per_page = params[:per_page] || 8
    @articles = @account.articles.published_or_scheduled.paginate(:all, :page => page, :per_page => per_page, :order => 'published_at desc')
    logger.info "Lead articles: #{current_lead_articles.inspect}"
    @lead_articles = current_lead_articles
  end
  
  def update
    @account.lead_article_ids = params[:lead_article_ids]
    @account.current_design.update_attribute(:current_front_page_template_id, params[:current_front_page_template_id]) if @account.current_design
    @account.save
    redirect_to account_articles_url(@account)
  end 
end
