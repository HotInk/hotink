require 'spec_helper'

describe PublicCommentsController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "POST to create" do
    context "with valid comment and empty honeypot" do
      before do
        @article = Factory(:article, :account => @account)
        post :create, :comment => { :name => "Chris", :email => "chris@email.com", :body => "This is a comment", :document_id => @article.id, :confirm_email => "" }
      end
    
      it { should respond_with(:redirect) }
      it "should create comment" do
        should assign_to(:comment).with_kind_of(Comment)
        assigns(:comment).should_not be_new_record
      end
      it "should assign comment to appropriate document" do
        assigns(:comment).document.should eql(@article)
      end
    end
  end
  
end