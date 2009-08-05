class RemoteSessionsController < ApplicationController

  def new
    @app = ClientApplication.find_by_key(params[:key], :order=>'created_at DESC')
    @access_token = AccessToken.find_by_user_id_and_client_application_id(current_user.id, @app.id)
    
    if @access_token
      # If an access token is fine, send everything necessary back to the app, but sign the request for security.
      query_string = "?oauth_token=#{@access_token.token}&sig=#{Digest::SHA1.hexdigest(@access_token.token + @access_token.secret)}"
      query_string += "&request_url=#{params[:request_url]}" if params[:request_url]
      redirect_to(@app.callback_url + query_string )
    else
      query_string = "?session_action=new_user"
      query_string += "&request_url=#{params[:request_url]}" if params[:request_url]
      redirect_to(@app.callback_url + query_string)
      return
    end  
         
  end
  
end
