class PrintingsController < ApplicationController
  
  before_filter :find_article, :only => [ :create, :destroy ]

  # POST /printings
  def create
    @printing = @account.printings.build(params[:printing])
    @printing.document = @article

    respond_to do |format|
      if @printing.save
        flash[:notice] = 'Printing recorded'
        format.html { redirect_to( edit_account_article_url(@account, @article) ) }
        format.js 
      end
    end
  end

  # DELETE /printings/1
  def destroy
    @printing = @article.printings.find(params[:id])
    @printing.destroy

    respond_to do |format|
      format.html { redirect_to( edit_account_article_url(@account, @article) ) }
      format.js
    end
  end
end
