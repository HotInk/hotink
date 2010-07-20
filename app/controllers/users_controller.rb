class UsersController < ApplicationController  
  permit "admin", :only => :deputize
  permit "(manager of account) or admin", :only => [:promote, :demote, :letgo ]
    
  def edit
    @user = current_user
    respond_to do |format|  
      format.js
    end
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated."
      respond_to do |format|  
        format.html { redirect_to account_url(@user.is_staff_for_what.first) }
        format.js   { head :ok }
      end
    else
      flash[:notice] = "Sorry, user update not valid"
      render :action => :edit
    end
  end
  
  def promote
    @user = User.find(params[:id])
    @account.promote(@user)
  end
  
  def demote
    @user = User.find(params[:id])
    @account.demote(@user)
  end
  
  def letgo
    @user = User.find(params[:id])
    if @user
      @account.accepts_no_role "staff", @user
    end
  end
    
  def deputize
    @user = User.find(params[:id])
    @user.promote_to_admin
  end
  
end
