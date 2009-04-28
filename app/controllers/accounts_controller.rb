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
    
    # General processing below, first account processing in "else" block.
    if Account.find(:first)

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @account }
      end
    else
      @user = User.new
      render :action=>"accounts/first_account/first_account_form", :layout=>'login'
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # Like #new, this action has variable effect depending on whether there are any existing accounts.
  def create
    @account = Account.new(params[:account])
    
    # General processing below, first account processing in "else" block.
    if Account.find(:first)
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
    else
      @user = User.new(params[:user])
      
      # User and account must be created simultaneously, we do this in a transaction.
      begin        
        ActiveRecord::Base.transaction do
          @account.save!
          @user.account = @account
          @user.has_role "admin"
          @user.save!
          @account.accepts_role "manager", @user
        end
      rescue ActiveRecord::RecordInvalid => invalid
        render :action=>"accounts/first_account/first_account_form", :layout=>'login'
        return
      end
      flash[:notice] = "Welcome to Hot Ink!"
      redirect_to account_articles_url(@user.account)
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
