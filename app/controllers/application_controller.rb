# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user

  before_filter :find_account

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '2b2fa863c84a38ce85b2ad73c4daac41'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  private
  
  def find_account
    if @account
      @account
    elsif params[:account_id]
      @account = Account.find(params[:account_id])
      Time.zone = @account.time_zone
      @account
    else
      @account = false
    end
  end
  
  def find_article
    if params[:article_id]
      @article = @account.articles.find(params[:article_id])
    else
      false
    end
  end
  
  def find_mediafile
    if params[:mediafile_id]
      @mediafile = @account.mediafiles.find(params[:mediafile_id])
    else
      false
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def require_user
    unless current_user
      store_location
      
      respond_to do |format|
        format.xml  { head :unauthorized  }
        format.html do
          flash[:notice] = "You must be logged in to access this page"
          redirect_to new_user_session_url
        end
      end
      
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end
