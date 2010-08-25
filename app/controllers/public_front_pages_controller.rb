class PublicFrontPagesController < PublicController
  skip_before_filter :verify_authenticity_token, :only => :preview
  
  def show
    if @design = design_to_render
      if @design == @account.current_design
        @front_page_template = @design.current_front_page_template || @design.front_page_templates.first
      else
        @front_page_template = @design.front_page_templates.first
      end
      context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
      render :text => @front_page_template.render({'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => context) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
  def preview
   permit "manager of account or admin" do
      if @design = @account.current_design
        @front_page_template = @design.front_page_templates.find(params[:preview_front_page_template_id]) 
        context = { :design => @design, :page => params[:page], :per_page => params[:per_page] }
        render :text => @front_page_template.render({'content' => ContentDrop.new(@account, :preview_lead_article_ids => params[:lead_article_ids]), 'site' => SiteDrop.new(@account)}, :registers => context) 
      else
        render :text => "This site is currently offline. You need to set a current design in order to preview this front page.", :status => :service_unavailable
      end
    end
  end
end
