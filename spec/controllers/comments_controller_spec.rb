require 'spec_helper'

describe CommentsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET to index" do
    before do
      @comments = (1..3).collect { |n| Factory(:comment, :account => @account, :created_at => (5.days.ago + n.hours)) }
      get :index
    end
    
    it { should respond_with(:success) }
    it { should render_with_layout(:hotink) }
    it { should assign_to(:comments).with(@comments.reverse) }
  end
  
  describe "GET to search" do
    before do
      @comments = (1..2).collect { Factory(:comment, :account => @account) }
    end
    
    context "with a query" do
      before do
        @searched_comments =(1..3).collect { Factory(:comment, :body => "Experimental testing", :account => @account) }
        Comment.should_receive(:search).and_return(@searched_comments)
        get :search, :q => "Experimental testing"
      end
    
       it { should respond_with(:success) }
       it { should respond_with_content_type(:html) }
       it { should render_template(:search) }
       it { should render_with_layout(:hotink) }
       it { should assign_to(:search_query).with("Experimental testing") }
       it { should assign_to(:comments).with(@searched_comments) }
    end
    
    context "with no query" do
      before do
        get :search
      end
      
      it { should respond_with(:success) }
      it { should render_template(:search) }
      it { should assign_to(:comments).with([]) }
    end
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
