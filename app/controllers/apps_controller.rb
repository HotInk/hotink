class AppsController < ApplicationController
  
  layout 'hotink'
  
  def show
    @app = ClientApplication.find(params[:id])
  end
  
end
