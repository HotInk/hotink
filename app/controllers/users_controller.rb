class UsersController < ApplicationController
  layout 'login'
  
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
  
end
