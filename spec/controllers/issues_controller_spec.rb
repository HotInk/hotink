require 'spec_helper'

describe IssuesController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
  end
  
  context "when logged in" do
    before do
      controller.stub!(:login_required).and_return(true)
    end
    
    describe "GET to index" do
      before do
        @issues = (1..3).collect{ Factory(:issue, :account => @account) }
        get :index  
      end

      it { should assign_to(:issues).with(@issues) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end

    describe "GET to new" do
      before do
        get :new
      end

      it { should assign_to(:issue).with_kind_of(Issue) }
      it { should respond_with(:redirect) }
    end

    describe "PUT to update" do
      before do
        @issue = Factory(:issue, :account => @account)
      end

      context "with valid attributes" do
        before do
          put :update, :id => @issue.id, :issue => Factory.attributes_for(:issue)
        end

        it { should assign_to(:issue).with(@issue) }
        it { should respond_with(:redirect) }
        it { should set_the_flash.to('Issue saved.') }
      end

      context "with valid attributes" do
        before do
          post :update, :id => @issue.id, :issue => Factory.attributes_for(:issue, :date => "Tomorrow")
        end

        it { should assign_to(:issue).with(@issue) }
        it { should respond_with(:bad_request) }
        it { should respond_with_content_type(:html) }
        it { should render_template(:edit) }
      end
    end

    describe "GET to edit" do
      before do
        @issue = Factory(:issue, :account => @account)
      end

      context "with HTML request" do
        before do
          get :edit, :id => @issue.id
        end

        it { should assign_to(:issue).with(@issue) }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:html) }
      end

      context "with XHR request" do
        before do
          xhr :get, :edit, :id => @issue.id
        end

        it { should assign_to(:issue).with(@issue) }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:js) }
      end
    end

    describe "DELETE to destroy" do
      before do
        @issue = Factory(:issue, :account => @account)
        delete :destroy, :id => @issue.id
      end

      it { should respond_with(:redirect) }
      it "should delete the article" do
        lambda { Issue.find(@issue.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  context "when not logged in but holding valid user credentials" do
    before do
      @user = Factory(:user)
      @user.has_role('staff', @account)
      @issue = Factory(:issue, :account => @account)
      
      post :upload_pdf, :id => @issue.id, :user_credentials => @user.single_access_token, :Filedata => fixture_file_upload('/test-pdf.pdf')
    end
    
    it { should assign_to(:issue).with(@issue) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should update the issue PDF" do
      @issue.reload.pdf_file_name.should == "test-pdf.pdf"
    end
  end
  
  context "when not logged in and not holding valid user credentials" do
    before do
      @user = Factory(:user)
      @issue = Factory(:issue, :account => @account)
      
      post :upload_pdf, :id => @issue.id, :user_credentials => @user.single_access_token, :Filedata => fixture_file_upload('/test-pdf.pdf')
    end
    
    it { should respond_with(:unauthorized) }
  end
end
