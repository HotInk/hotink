class PublicArticlesController < PublicController
  
  def show
    if @design = design_to_render
       if current_user
          @article = @account.articles.find(params[:id])
       else
          @article = @account.articles.published.find(params[:id])
       end
       render :text => @design.article_template.render({'article' => ArticleDrop.new(@article), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => { :design => @design, :form_authenticity_token => form_authenticity_token })
    else
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
end