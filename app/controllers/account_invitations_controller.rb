class AccountInvitationsController < ApplicationController
  
  skip_before_filter :login_required, :only => [:edit, :update]
  skip_before_filter :find_account
  
  layout 'login'
  
  permit 'admin', :only => [:create, :destroy]
  
  def create
    @invite = AccountInvitation.new(params[:invitation])
    flash[:account_invitation_notice] = "Account invitation sent."

    @invite.user = current_user
    
    if @invite.save
      @accounts = Account.all
    else
      flash[:account_invitation_notice] = "Can't work with that. It's not a valid email."
    end    
  end
  
  def edit
    @invite = AccountInvitation.find_by_token(params[:id])
    @account = Account.new
    if @invite.redeemed?
      redirect_to login_url
    else
      @user = User.find_or_initialize_by_email(:email => @invite.email) 
    end
  end
  
  def update
    @invite = AccountInvitation.find_by_token(params[:id])
    if @invite.redeemed?
      redirect_to login_url
    else
      @user = load_user
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
        redirect_to admin_url(:subdomain => @account.name)
      rescue ActiveRecord::RecordInvalid
        unless @user.new_record?
          @user.destroy
          @user = load_user # Errors on @account in transaction will leave @user thinking it was saved
        end
        render :edit
      end
    end
  end
  
  def destroy
    @invite = AccountInvitation.find_by_token(params[:id])
    @invite.destroy if permit?('admin')
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
