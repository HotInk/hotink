class TemplatesController < ApplicationController
  
  permit "admin"
  
  # GET /templates/new
  def new
    @design = @account.designs.find(params[:design_id])

    case params[:role]
    when nil
      raise ArgumentError, "Must assign a template role"
    when 'layout'
      @tplate = @design.layouts.build
    when 'partial'
      @tplate = @design.partial_templates.build
    when 'front_page'
      @tplate = @design.front_page_templates.build
    end
  end
  
  # GET /templates/1/edit
  def edit
    @design = @account.designs.find(params[:design_id])
    
    @tplate = @design.templates.find(params[:id])
  end
  
  # POST /templates
   def create
     @design = @account.designs.find(params[:design_id])

     if params[:layout]
        @tplate = @design.layouts.build(params[:layout])
     elsif params[:partial_template]
        @tplate = @design.partial_templates.build(params[:partial_template])
     elsif params[:front_page_template]
       @tplate = @design.front_page_templates.build(params[:front_page_template])
     end

     if @tplate.save
       flash[:notice] = 'Template created'
       redirect_to account_design_path(@account, @design)
     else
       render :new
     end
     
   rescue Liquid::SyntaxError => e
     flash[:syntax_error] = "#{e.message}"
     render :action => "new"
   end
   
   
   # PUT /templates/1
   def update     
     @design = @account.designs.find(params[:design_id])
         
     @tplate = @design.templates.find(params[:id])
     @tplate.update_attributes(params[@tplate.class.name.underscore.to_sym])
     flash[:notice] = 'Template updated'
     redirect_to account_design_url(@account, @design) 

   rescue Liquid::SyntaxError => e
     flash[:syntax_error] = "#{e.message}"
     @tplate.code = params[@tplate.class.name.underscore.to_sym][:code]
     render :action => "edit"
   end
   
   # DELETE /templates/1
   def destroy
     @design = @account.designs.find(params[:design_id])
     
     @tplate = @design.templates.find(params[:id])

     @tplate.destroy

     flash[:notice] = "Template removed"
     redirect_to account_design_url(@account, @design)
   end
end
