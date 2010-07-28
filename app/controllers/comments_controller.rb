class CommentsController < ApplicationController

  layout "hotink"
  
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 30
    @comments = @account.comments.paginate(:page => page, :per_page => per_page, :order => "created_at desc")
  end
  
  def search
    if params[:q]
      page = params[:page] || 1
      per_page = params[:per_page] || 10  
      @search_query = params[:q]
      @comments = Comment.search(@search_query, :page => page, :per_page => per_page)
    else
      @comments = []
    end
  end
  
  
  def destroy
    @comment = @account.comments.find(params[:id])
    @comment.destroy
  end
  
end