class InvitationsController < ApplicationController
  skip_before_filter :login_required, :only => [:edit, :update]
  
  def create
    if params[:invitation][:type]=='AccountInvitation'
      if permit?('admin')
        @invite = AccountInvitation.new(params[:invitation])
        flash[:notice] = "Account invitation sent."
      end
    else
      @invite = @account.user_invitations.build(params[:invitation])
      flash[:notice] = "User contacted and added to your account"
    end

    @invite.user = current_user
    
    unless @invite.save
      flash[:notice] = "Can't work with that. It's not a valid email."
    end    
    
    if @invite.is_a?(AccountInvitation)
      @accounts = Account.all
      render :partial => 'accounts/accounts_window'
    else
      render :partial => 'accounts/users_window'
    end
  end
  
  def edit
    if @account
      @invite = @account.user_invitations.find_by_token(params[:id])
    else
      @invite = AccountInvitation.find_by_token(params[:id])
      @account = Account.new
    end
    if @invite.redeemed?
      redrect_to login_url
    else
      @user = User.find_or_initialize_by_email(:email => @invite.email) 
    
      if @invite.is_a?(AccountInvitation)
        render :template => 'account_invitations/edit', :layout => 'login'
      else
        render :template => 'user_invitations/edit', :layout => 'login'
      end
    end
  end
  
  def update
    @invite = Invitation.find_by_token(params[:id])
    if !@invite.redeemed?
      
      @user = load_user
      
      if @invite.is_a?(AccountInvitation)
        @account = Account.new(params[:account])
        begin
          Account.transaction do
            @user.save!
            @account.save!
            @invite.redeem!
          end
          @user.has_role('staff', @account)
          @user.has_role('manager', @account)
          flash[:notice] = "Your account has been created! Please login to confirm your user credentials."
          redirect_to account_url(@account)
          
        rescue ActiveRecord::RecordInvalid
          @user = load_user # Errors on @account in transaction will leave @user thinking it was saved
          render :template => 'account_invitations/edit', :layout => 'login'

        end
      else
        if @user.save
          @invite.redeem!
          @user.has_role('staff', @account)
          flash[:notice] = "Please login to confirm your credentials."
          redirect_to login_url
          
        else
          render :template => 'user_invitations/edit', :layout => 'login'

        end    
      end
    
    else
      redirect_to login_url
    end
  end
  
  def destroy
    @invite = Invitation.find_by_token(params[:id])
    if @invite.is_a? AccountInvitation
      @invite.destroy if permit?('admin')
      @accounts = Account.all
      render :partial => 'accounts/accounts_window'
    else
      @invite.destroy if permit?('(manager of account) or admin')
      render :partial => 'accounts/users_window'
    end
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
