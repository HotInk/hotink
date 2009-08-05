class AppsController < ApplicationController
  
  layout 'apps'
  
  def show
    @app = ClientApplication.find(params[:id])
    query_string = Hash.new
    query_string.merge!(:account_id => @account.id) if @account && @app.include=="account_id"
    if @app.include
       @iframe_url = "#{@app.callback_url}?#{query_string.to_query}"
     else
       @iframe_url = @app.callback_url
    end
  end
  
end
