class UsersController < ApplicationController  
  permit "admin", :only => :deputize
  permit "(manager of account) or admin", :only => [:promote, :demote, :letgo ]
    
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      respond_to do |format|  
        format.html do
          flash[:notice] = "User updated."
          redirect_to account_dashboard_url(@user.is_staff_for_what.first)
        end
        format.js
      end
    else
      respond_to do |format|  
        format.html do
          flash[:notice] = "Sorry, user update not valid"
          redirect_to account_dashboard_url(@user.is_staff_for_what.first)
        end
        format.js { render :action => :edit }
      end
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
