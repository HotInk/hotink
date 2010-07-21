class IssuesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required, :only => :upload_pdf
  
  layout 'hotink'
  
  # GET /issues
  def index 
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 15 ).to_i
    @issues = @account.issues.paginate( :page=>page, :per_page =>per_page, :order => "date DESC")
    
    respond_to do |format|
      format.html
    end
  end

  # GET /issues/1
  def show
    @issue = @account.issues.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /issues/new
  def new
    @issue = @account.issues.create(:date => Time.now)
    
    respond_to do |format|
      format.html { redirect_to edit_account_issue_url(@account, @issue ) }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = @account.issues.find(params[:id])
 
    respond_to do |format|
      format.html # edit.html.erb
      format.js   # edit.js.rjs
    end
  end

  # PUT /issues/1
  def update
    @issue = @account.issues.find(params[:id])
    #date= @issue.date

    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        flash[:notice] = 'Issue saved.'
        format.html { redirect_to account_issues_url(@account) }
      else
        #@issue.date = date
        format.html { render :action => "edit", :status => :bad_request }
      end
    end
  end

  # DELETE /issues/1
  def destroy
    @issue = @account.issues.find(params[:id])
    @issue.destroy

    respond_to do |format|
      format.html { redirect_to(account_issues_url(@account)) }
    end
  end
    
  # As a limitation of SWFUpload, this action has to skip authntication an reinstitute its own. 
  def upload_pdf
    user = User.find_by_single_access_token(params['user_credentials'])
    if user
      session[:checkpoint_user_id] = user.id 
      user.reset_single_access_token!
    end
    if authorized?
      @issue = @account.issues.find(params[:id])
      @issue.swfupload_file = params[:Filedata]
      flash[:notice] = "PDF uploaded" if @issue.save
      respond_to do |format|
          format.html do # After an image upload, reload the page with javascript          
            render :update do |page|
                page.replace  'issue', :partial => 'form'
            end         
          end
      end
    else
      render :text => "unauthorized", :status => 401
    end
  end
  
  private
  
  def single_access_allowed?
    action_name == 'upload_pdf'
  end
  
end
