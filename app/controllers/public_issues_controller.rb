class PublicIssuesController < PublicController
    
  def show
    if @design = design_to_render
     @issue = @account.issues.find(params[:id])
     render :text => @design.issue_template.render({'issue' => IssueDrop.new(@issue), 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => { :design => @design }) 
    else  
     render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
  def index
    if @design = design_to_render
      @issues =  @account.issues.find(:all, :order => "date desc")
      render :text => @design.issue_index_template.render({'issues' => @issues.collect{ |issue| IssueDrop.new(issue) }, 'content' => ContentDrop.new(@account), 'site' => SiteDrop.new(@account)}, :registers => { :design => @design }) 
    else  
      render :text => "This site is currently offline.", :status => :service_unavailable
    end
  end
  
end
