class PublicPagesController < PublicController
    
  def show
    @page = @account.pages.find_by_path(params[:id])
    if @page.template
      context = { :design => @page.template.design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @page.template.render({'page' => PageDrop.new(@page), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else
      contents = @page.contents ? @page.contents : ""
      render :text => RDiscount.new(contents).to_html
    end
  end
  
end
