require 'spec_helper'

describe CommentsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "DELETE to destroy" do
    before do
      @comment = Factory(:comment, :account => @account)
      delete :destroy, :document_id => @comment.document, :id => @comment.id
    end
    
    it { should respond_with(:success) }
    it "should destroy comment" do
      lambda { @account.comments.find(@comment.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
