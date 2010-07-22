class NetworksController < ApplicationController
  
  def show
    @memberships = @account.network_memberships
    @articles = Article.published.find(:all, :order => "published_at desc", :conditions => { :account_id => @memberships.collect{ |m| m.account_id } })
  end
  
end
