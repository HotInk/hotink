class PrintingsController < ApplicationController
  
  before_filter :find_article

  # POST /printings
  def create
    @printing = @account.printings.create(params[:printing].merge(:document => @article))
    flash[:notice] = 'Printing recorded'
    
    respond_to do |format|
        format.js 
    end
  end

  # DELETE /printings/1
  def destroy
    @printing = @article.printings.find(params[:id])
    @printing.destroy

    respond_to do |format|
      format.js
    end
  end
end
