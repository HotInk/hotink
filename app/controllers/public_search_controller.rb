class PublicSearchController < PublicController
    
  def show
    if @design = design_to_render
      if params[:q]
        @hits = @account.articles.published.search(params[:q], :order => "published_at desc")
      else
        @hits = []
      end
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @design.search_results_template.render({'search_results' => @hits.collect{ |a| ArticleDrop.new(a) }, 'query' => params[:q], 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
