class UsersController < ApplicationController
  layout 'login'
  
  permit "admin", :only => :deputize
  permit "manager of account", :only => [:promote, :demote]
    
  # Users are created via activations, so no "new" or "create" methods exist in this controller.
  # This also helps thwart smart users who try parameter hacking to create their own user.

  def show
    @user = current_user
  end

  def edit
    @user = current_user
    respond_to do |format|  
      format.html 
      format.js
    end
  end

  def update
    @user = current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated."
      respond_to do |format|  
        format.html { redirect_to user_url(@user) }
        format.js   { head :ok }
      end
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
    
  def deputize
    @user = User.find(params[:id])
    if @user
      @user.has_role 'admin'
      render @user
    end
  end
  
end
