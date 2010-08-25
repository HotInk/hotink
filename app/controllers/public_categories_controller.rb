class PublicCategoriesController < PublicController
  
  def show
    if @design = design_to_render
      @category = @account.categories.find_by_path(params[:id])      
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @design.category_template.render({'category' => CategoryDrop.new(@category), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end

end
