class PublicPagesController < ApplicationController
  
  skip_before_filter :login_required
  
  def show
    if @design = design_to_render
      @page = @account.pages.find_by_path(params[:id])
      render :text => @design.page_template.render({'page' => PageDrop.new(@page), 'content' => ContentDrop.new, 'site' => SiteDrop.new}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
