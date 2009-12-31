class AppsController < ApplicationController
  
  layout 'apps'
  
  def show
    @app = SsoConsumer.find(params[:id])
    @iframe_url = "#{@app.url.split('/sso/login')[0]}/accounts/#{@account.id}#{@app.landing_url}"
  end
  
end
