class PublicArticlesController < PublicController
  
  def show
    if @design = design_to_render
       if current_user
          @article = @account.articles.find(params[:id])
       else
          @article = @account.articles.published.find(params[:id])
       end
       context = { :design => @design, :page => params[:page], :per_page => params[:per_page], :form_authenticity_token => form_authenticity_token }
       render :text => @design.article_template.render({'article' => ArticleDrop.new(@article), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context)
    else
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
end