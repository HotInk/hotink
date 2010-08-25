class PublicEntriesController < PublicController
  
  def show
    if @design = design_to_render
      @blog = @account.blogs.find(:first, :conditions => { :slug => params[:blog_slug] })
      if current_user
        @entry = @blog.entries.find(params[:id])
      else
        @entry = @blog.entries.published.find(params[:id])
      end
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @design.entry_template.render({'entry' => EntryDrop.new(@entry), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
