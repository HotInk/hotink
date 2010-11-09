class PublicFeedsController < PublicController
  
  def show
    @feed_title = "#{@account.display_name} RSS feed"
    @articles = @account.articles.published.find  :all, 
                                                  :order =>"published_at desc", 
                                                  :limit => @account.feed_settings.limit
    respond_to do |format|
      format.xml
    end
  end
  
end
