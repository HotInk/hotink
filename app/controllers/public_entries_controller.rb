class PublicEntriesController < ApplicationController

  skip_before_filter :login_required
  
  def show
    if @design = design_to_render
      @blog = @account.blogs.find(:first, :conditions => { :slug => params[:blog_slug] })
      if current_user
        @entry = @blog.entries.find(params[:id])
      else
        @entry = @blog.entries.published.find(params[:id])
      end
      render :text => @design.entry_template.render({'entry' => EntryDrop.new(@entry), 'content' => ContentDrop.new, 'site' => SiteDrop.new}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
