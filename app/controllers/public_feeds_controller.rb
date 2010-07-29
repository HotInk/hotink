class PublicFeedsController < ApplicationController
  skip_before_filter :login_required
  
  def show
    @feed_title = "#{@account.display_name} RSS feed"
    @articles = @account.articles.published.find(:all, :order =>"published_at desc", :limit => 250)
    respond_to do |format|
      format.xml
    end
  end
  
end
