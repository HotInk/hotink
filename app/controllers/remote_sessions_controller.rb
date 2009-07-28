class RemoteSessionsController < ApplicationController

  def new
   
    @app = ClientApplication.find_by_key(params[:key], :order=>'created_at DESC')
    @access_token = AccessToken.find_by_user_id_and_client_application_id(current_user.id, @app.id)
    
    if @access_token
      # If an access token is fine, send everything necessary back to the app, but sign the request for security.
      redirect_to(@app.callback_url + "?oauth_token=#{@access_token.token}&sig=#{Digest::SHA1.hexdigest(@access_token.token + @access_token.secret)}")
    else
      redirect_to(@app.callback_url + "?session_action=new_user")
      return
    end  
         
  end
  
end
