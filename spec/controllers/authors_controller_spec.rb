require 'spec_helper'

describe AuthorsController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to index" do
    before do
      @authors = (1..5).collect{ Factory(:author, :account => @account) }
    end
    
    describe "getting JSON list of all an account's authors" do
      before do
        get :index, :account_id => @account.id
      end
      
      it { should assign_to(:authors).with(@author) }
      it { should respond_with_content_type(:json) }
    end
    
    describe "getting JSON list of one article's authors" do
      before do
        @article = Factory(:article, :authors => @authors, :account => @account)
        get :index, :account_id => @account.id, :article_id => @article.id
      end
      
      it { should assign_to(:authors).with(@author) }
      it { should respond_with_content_type(:json) }
    end
  end
  
  describe "POST to create" do
    before do
      post :create, :account_id => @account.id, :author => { :name => "Nice one" }
    end
    
    it { should respond_with(:created) }
    it { should respond_with_content_type(:json) }
    it "should create the author" do
      should assign_to(:author).with_kind_of(Author)
      assigns(:author).should_not be_new_record
      assigns(:author).name.should == "Nice one"
    end
  end
end
