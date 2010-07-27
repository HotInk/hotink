class PublicCommentsController < ApplicationController
  skip_before_filter :login_required
  
  def create
    @document = @account.documents.find(params[:comment][:document_id])
    if params[:comment].delete(:confirm_email)==""
      @comment = @account.comments.create(params[:comment].merge({ :ip_address => request.remote_ip }))
    end
    if @document.is_a? Article
      redirect_to public_article_path(@document)
    elsif @document.is_a? Entry
      redirect_to public_blog_entry_path(@document.blog, @document)
    end
  end
end
