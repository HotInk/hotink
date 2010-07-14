require 'spec_helper'

describe AuthorsController do
  before do
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)  
    
    @account = Factory(:account)
  end
  
  describe "GET to index" do
    before do
      @authors = (1..5).collect{ Factory(:author, :account => @account) }
      @wills = [Factory(:author, :name => "Will Number 1", :account => @account), Factory(:author, :name => "Second Will", :account => @account)]
    end
    
    describe "getting JSON list of all authors" do
      before do
        get :index, :account_id => @account.id
      end
      
      it { should assign_to(:authors).with(@authors + @wills) }
      it { should respond_with_content_type(:json) }
    end
    
    describe "getting a list of specific authors" do
      before do
        get :index, :account_id => @account.id, :q => "will"
      end
      
      it { should assign_to(:authors).with(@wills) }
      it { should respond_with_content_type(:json) }
    end   
    
    describe "only get current account authors" do
      before do
        get :index, :account_id => Factory(:account).id
      end
      
      it { should assign_to(:authors).with([]) }
      it { should respond_with_content_type(:json) }
    end 
  end

end
