class PublicController < ApplicationController
  skip_before_filter :login_required
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    raise ActiveRecord::RecordNotFound unless @account
    if @design = design_to_render
      rendered_page =  @design.not_found_template.render({'content' => ContentDrop.new(@account), 'site' => SiteDrop.new}, :registers => { :design => @design })
      render :text => rendered_page, :status => :not_found
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
end