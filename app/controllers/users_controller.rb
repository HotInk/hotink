class UsersController < ApplicationController
  layout 'login'
  
  permit "admin", :only => :deputize
  permit "manager of account", :only => :promote
  
  before_filter :require_user, :except=>[:new, :create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "User registered."
      redirect_back_or_default user_url(@user)
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated."
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end
  
  def promote
    @user = @account.users.find(params[:id])
    if @user
      @account.accepts_role 'manager', @user
      render @user
    end
  end
  
  def demote
    @user = @account.users.find(params[:id])
    if @user
      @account.accepts_no_role 'manager', @user
      render @user
    end
  end
    
  def deptuize
    @user = Users.find(params[:id])
    if @user
      @user.has_role 'admin'
      render @user
    end
  end
  
end
