class CommentsController < ApplicationController

  def destroy
    @comment = @account.comments.find(params[:id])
    @comment.destroy
  end
  
end