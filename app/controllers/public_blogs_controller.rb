class PublicBlogsController < ApplicationController
  
  skip_before_filter :login_required
  
  def show
    if @design = design_to_render
      @blog = @account.blogs.active.find_by_slug(params[:id])
      render :text => @design.blog_template.render({'blog' => BlogDrop.new(@blog), 'content' => ContentDrop.new, 'site' => SiteDrop.new}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
  def index
    if @design = design_to_render
      @blogs = @account.blogs.active.all
      render :text => @design.blog_index_template.render({'blogs' => @blogs.collect{ |blog| BlogDrop.new(blog) }, 'content' => ContentDrop.new, 'site' => SiteDrop.new}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
