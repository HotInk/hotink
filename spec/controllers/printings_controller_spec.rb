require 'spec_helper'

describe PrintingsController do
  before do
    controller.stub!(:login_required).and_return(true)
    @account = Factory(:account)
    @article = Factory(:article, :account => @account)
    @issue = Factory(:issue, :account => @account)
  end
  
  describe "POST to create" do
    context "with XHR request" do
      before do
        xhr :post, :create, :account_id => @account.id, :article_id => @article.id, :printing => { :issue_id => @issue.id }
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it "should create a printing" do
        should assign_to(:printing).with_kind_of(Printing)
        assigns(:printing).should_not be_new_record
        assigns(:printing).issue.should == @issue
        assigns(:printing).document.should == @article
      end
    end
  end
  
  describe "DELETE to destroy" do
    before do
      @printing = Printing.create(:account => @account, :document => @article, :issue => @issue)
    end
    
    context "with XHR request" do
      before do
        xhr :delete, :destroy, :account_id => @account.id, :article_id => @article.id, :id => @printing.id
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it "should delete the printing" do
        should assign_to(:printing).with(@printing)
        lambda{ Printing.find(@printing.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

  end
  
end
