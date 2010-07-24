class NetworksController < ApplicationController
  
  layout 'hotink'
  
  def show
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    @memberships = @account.network_memberships
    @articles = Article.published.paginate(:page => page, :per_page => per_page, :order => "published_at desc", :conditions => { :account_id => @memberships.collect{ |m| m.account_id } })
  end
  
  def show_article
    @article = Article.find(params[:id], :conditions => { :account_id => @account.network_member_ids })
  end
  
  def checkout_article
    @article = Article.find(params[:id], :conditions => { :account_id => @account.network_member_ids })
    @account.make_network_copy(@article, current_user)
    flash[:notice] = "Article copied"
    redirect_to account_network_show_article_path(@account, @article)
  end
  
  def show_members
    @accounts = Account.find(:all, :order => "name asc") - [@account]
  end
  
  def update_members
    @account.network_member_ids = params[:member_ids]
    redirect_to :action => :show_members
  end
  
end
