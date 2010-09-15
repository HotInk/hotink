class UserInvitationsController < ApplicationController
  
  skip_before_filter :login_required, :only => [:edit, :update]
  
  layout 'login'
  
  permit "admin or manager of account", :only => [:create, :destroy]
  
  def create
    @invite = @account.user_invitations.build(params[:invitation])
    @invite.user = current_user
    
    if @invite.save
      flash[:user_invitation_notice] = "User contacted and added to your account"
    else
      flash[:user_invitation_notice] = "Can't work with that. It's not a valid email."
    end    
  end
  
  def edit
    @invite = @account.user_invitations.find_by_token(params[:id])
    
    raise ActiveRecord::RecordNotFound unless @invite
    
    if @invite.redeemed?
      redirect_to login_url
    else
      @user = User.find_or_initialize_by_email(:email => @invite.email) 
    end
  end
  
  def update
     @invite = @account.user_invitations.find_by_token(params[:id])
     
     raise ActiveRecord::RecordNotFound unless @invite
     
     if @invite.redeemed?
       redirect_to login_url
     else
       @user = load_user
       if @user.save
         @invite.redeem!
         @user.has_role('staff', @account)
         flash[:notice] = "Please login to confirm your credentials."
         redirect_to login_url
       else
         render :template => 'user_invitations/edit', :layout => 'login'
       end
     end
   end
   
   def destroy
     @invite = @account.user_invitations.find_by_token(params[:id])
     @invite.destroy if permit?('(manager of account) or admin')
   end
   
   
   private
   
   def load_user
     if params[:user_id]
       User.find(params[:user_id])
     else
       User.new(params[:user])
     end
   end
end
