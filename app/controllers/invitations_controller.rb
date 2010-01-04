class InvitationsController < ApplicationController
  skip_before_filter :login_required, :only => [:edit, :update]
  
  def create
    @invite = @account.invitations.build(params[:invitation])
    @invite.user = current_user
    if @invite.save
      flash[:notice] = "User contacted and added to your account"
    else
      flash[:notice] = "Can't work with that. It's not a valid email."
    end
    render :partial => 'accounts/users_window'
  end
  
  def edit
    @invite = @account.invitations.find_by_token(params[:id])
    @user = User.new(:login => @invite.email.split('@')[0], :email => @invite.email) 
    
    render :action => :edit, :layout => 'login'
  end
  
  def update
    @invite = @account.invitations.find_by_token(params[:id])
    @user = User.new(params[:user])
    
    if !@invite.redeemed? && @user.save
      @invite.redeem!
      @account.promote(@user)
      flash[:notice] = "Please login to confirm your credentials."
      redirect_to login_url
    else
      render :action => :edit, :layout => 'login'
    end
  end
  
  def destroy
    @invite = @account.invitations.find_by_token(params[:id])
    @invite.destroy
    render :partial => 'accounts/users_window'
  end
end
