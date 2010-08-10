class PublicPagesController < PublicController
    
  def show
    if @design = design_to_render
      @page = @account.pages.find_by_path(params[:id])
      logger.info @design.page_template.inspect
      render :text => @design.page_template.render({'page' => PageDrop.new(@page), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
