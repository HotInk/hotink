class AppsController < ApplicationController
  
  layout 'apps'
  
  def show
    @app = ClientApplication.find(params[:id])
  end
  
end
