class AccountsController < ApplicationController
  skip_before_filter :find_account
  layout 'login', :only=>[:new, :create]
  layout 'hotink', :only=>:edit
  
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.find(:all)
    if @accounts.blank?
      redirect_to new_account_url
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # The new account action has two different behaviours. It helps create accounts on an existing
  # Hot Ink installation, but it also handles the Hot Ink installation wizard.
  def new
    @account = Account.new
    
    # First account processing below, general processing in "else" block.
    if Account.all.blank?
      @user = User.new
      render :action=>"accounts/first_account/first_account_form", :layout=>'login'
    else
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @account }
      end
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
    
    # Invited users have an account id but have not been edited.
    @user_activations = User.find(:all, :conditions => "account_id=#{@account.id} AND created_at = updated_at")
    if permit? "admin", current_user 
      @accounts = Account.find(:all)
      # Users invited to open an account have no account id
      @account_activations = User.find(:all, :conditions => { :account_id => nil })
    end
  end

  # Like #new, this action has variable effect depending on whether there are any existing accounts.
  def create
    @account = Account.new(params[:account])
    
    # First account processing below, general processing in "else" block.
    if Account.all.blank?     
      @user = User.new(params[:user])  
          
      # An admin user and an account must both be created for the system to work.
      # We do this in a transaction. Transactions only work if an error is both raised
      # and caught before it stops the action from processing.
      begin        
        ActiveRecord::Base.transaction do
          @account.save!
          @user.account = @account
          @user.has_role "admin"
          @user.save!
          @account.accepts_role "manager", @user # Gives admin control over account
          @account.accepts_role "staff", @user # Makes user a staff member of the account
        end
      rescue ActiveRecord::RecordInvalid => invalid
        render :action=>"accounts/first_account/first_account_form", :layout=>'login'
        return
      end
      flash[:notice] = "Welcome to Hot Ink!"
      redirect_to account_articles_url(@user.account)
    else
        respond_to do |format|
            if @account.save
                flash[:notice] = "Account created"
                format.html { redirect_to(accounts_url) }
                format.xml  { render :xml => @account, :status => :created, :location => @account }
            else
              format.html { render :action => "new" }
              format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
            end
        end
    end
    
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = "Account updated"
        format.html { redirect_to(account_articles_url(@account)) }
        format.js { head :ok } #The categories-list on the article form posts here. This is it's js. 
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
end
