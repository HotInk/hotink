class IssuesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  
  layout 'hotink'
  
  # GET /issues
  # GET /issues.xml
  def index
    @issues = @account.issues.paginate( :page=>(params[:page] || 1), :per_page => (params[:per_page] || 15 ), :order => "date DESC")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
    end
  end

  # GET /issues/1
  # GET /issues/1.xml
  def show
    @issue = @account.issues.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
    end
  end
  
  #Return an issue's articles in the api
  def articles
    @issue = @account.issues.find(params[:id])
    
    if params[:section_id]
      @articles = @issue.articles.find_all_by_section_id(params[:section_id], :conditions => { :status => 'published' })
    else
      @articles = @issue.articles.find( :all, :conditions => { :status => 'published' } )
    end
        
    respond_to do |format|
      format.xml  { render :xml => @articles }
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
      format.xml  { render :xml => @issue }
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
        format.xml  { render :xml => @issue, :status => :created, :location => [@account, @issue] }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
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
        format.xml  { head :ok }
      else
        @issue.date = date
        format.html { render :action => "edit" }
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
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
      format.xml  { head :ok }
    end
  end
    
  def upload_pdf
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
  end
  
  private
  
  def single_access_allowed?
    action_name == 'upload_pdf'
  end
  
end
