class PublicBlogsController < PublicController
  
  def show
    if @design = design_to_render
      @blog = @account.blogs.active.find :first, :conditions => { :slug => params[:id] }
      raise ActiveRecord::RecordNotFound unless @blog
      
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @design.blog_template.render({'blog' => BlogDrop.new(@blog), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
  def index
    if @design = design_to_render
      @blogs = @account.blogs.active.all
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @design.blog_index_template.render({'blogs' => @blogs.collect{ |blog| BlogDrop.new(blog) }, 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
