class IssuesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required, :only => :upload_pdf
  
  layout 'hotink'
  
  # GET /issues
  # GET /issues.xml
  def index 
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 15 ).to_i
    @issues = @account.issues.paginate( :page=>page, :per_page =>per_page, :order => "date DESC")
    
    respond_to do |format|
      format.html
    end
  end

  # GET /issues/1
  # GET /issues/1.xml
  def show
    @issue = @account.issues.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /issues/new
  # GET /issues/new.xml
  def new
    @issue = @account.issues.build(:date => Time.now )
        
    #Check to see if the last issue created is exists and is untouched.
    #If so, redate it and serve it up instead of a new article, to prevent
    #the data from becoming cluttered with abandoned articles.
    #
    #If the last article was legit, save the fresh article so it can have relationships 
    if last_issue = @account.issues.find(:last)
      if last_issue.created_at == last_issue.updated_at
         @issue = last_issue
         @issue.date = Time.now #Give it the current time, without saving.
      else
        @issue.save
      end
    else
      @issue.save
    end
    
    respond_to do |format|
      format.html { redirect_to edit_account_issue_url(@account, @issue ) }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
 
    respond_to do |format|
      format.html # edit.html.erb
      format.js   # edit.js.rjs
    end
  end

  # POST /issues
  # POST /issues.xml
  def create
    @issue = Issue.new(params[:issue])
    @issue.account = @account

    respond_to do |format|
      if @issue.save
        flash[:notice] = 'Issue was successfully created.'
        format.html { redirect_to account_issues_url(@account) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # PUT /issues/1
  # PUT /issues/1.xml
  def update
    @issue = @account.issues.find(params[:id])
    date= @issue.date

    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        flash[:notice] = 'Issue was successfully updated.'
        format.html { redirect_to account_issues_url(@account) }
      else
        @issue.date = date
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.xml
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
                page.replace  'issue', :partial => 'issue_form'
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
