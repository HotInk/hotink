class UserSessionsController < ApplicationController
  layout 'login'
  skip_before_filter :login_or_oauth_required, :only => [:new, :create]
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      if @user_session.user.account
        redirect_back_or_default account_articles_url(@user_session.user.account)
      elsif @user_session.user.is_staff_for_what
        redirect_back_or_default account_articles_url(@user_session.user.is_staff_for_what.first)
      else
        render :status => 401
      end
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to new_user_session_url
  end
  
end

