class PublicFrontPagesController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => :preview
  
  def show
    if @design = design_to_render
      if @design == @account.current_design
        @front_page_template = @design.current_front_page_template || @design.front_page_templates.first
      else
        @front_page_template = @design.front_page_templates.first
      end
      render :text => @front_page_template.render({'content' => ContentDrop.new, 'site' => SiteDrop.new(@account)}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
  def preview
   permit "manager of account or admin" do
      if @design = @account.current_design
        @lead_articles = params[:lead_article_ids].collect{ |id| @account.articles.find_by_id(id) }
        @front_page_template = @design.front_page_templates.find(params[:preview_front_page_template_id]) 
        render :text => @front_page_template.render({'lead_articles' => @lead_articles.reject{ |a| !a.published? }.collect{ |b| ArticleDrop.new(b) }, 'content' => ContentDrop.new, 'site' => SiteDrop.new(@account)}, :registers => { :design => @design }) 
      else
        render :text => "This site is currently offline. You need to set a current design in order to preview this front page.", :status => :service_unavailable
      end
    end
  end
end
