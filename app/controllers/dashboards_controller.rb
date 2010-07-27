class DashboardsController < ApplicationController
  
  permit 'admin or staff of account'
  
  layout 'hotink'

  def dashboard_redirect
    redirect_to :action => :show
  end
  
  def show
    @lead_articles = @account.lead_article_ids.nil? ? [] : @account.lead_article_ids.collect{ |id| @account.articles.find_by_id(id) }
    @current_front_page_template = @account.current_design.current_front_page_template ||  @account.current_design.front_page_templates.first if @account.current_design
    @lists = @account.lists.find(:all, :limit => 3, :order => "updated_at desc")
    @blogs = @account.blogs.active.find(:all, :order => "blogs.updated_at desc").select{ |blog| blog.contributors.include?(current_user) }
  end
  
end
