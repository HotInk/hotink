require 'spec_helper'

describe MediafilesController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to index" do
    context "with no mediafiles" do
      before do
        get :index, :account_id => @account.id
      end

      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
      it { should render_with_layout(:hotink) }
      it { should assign_to(:mediafiles).with([]) }
    end

    context "searching for specific mediaifles" do
      before do
        @searched_mediafiles = (1..3).collect{ Factory(:mediafile, :account => @account) }
        @other_mediafiles = (1..3).collect{ Factory(:mediafile, :account => @account) }
        Mediafile.should_receive(:search).with( "test query", :with=>{ :account_id => @account.id }, :page => 1, :per_page => 20, :order => :date, :sort_mode => :desc, :include => [:authors]).and_return(@searched_mediafiles)
        get :index, :account_id => @account.id, :search => "test query"
      end

      it { should assign_to(:mediafiles).with(@searched_mediafiles) }
      it { should respond_with(:success) }
    end
      
    context "with XHR request" do
      before do
        xhr :get, :index, :account_id => @account.id
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
    end
  end
  
  describe "GET to show" do
    before do
      @mediafile = Factory(:mediafile, :account => @account)
      get :show, :account_id => @account.id, :id => @mediafile.id
    end
    
    it { should assign_to(:mediafile).with(@mediafile) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "GET to new" do
    before do
      @mediafile = Factory(:mediafile, :account => @account)
    end
    
    context "with XHR request" do
      context "relative to document" do
        before do
          @article = Factory(:article, :account => @account)
          xhr :get, :new, :account_id => @account.id, :document_id => @article.id
        end

        it { should assign_to(:mediafile).with_kind_of(Mediafile) }
        it { should respond_with_content_type(:js) }
      end
    end
    
    context "with HTML request" do
      before do
        get :new, :account_id => @account.id
      end
      
      it { should assign_to(:mediafile).with_kind_of(Mediafile) }
      it { should respond_with_content_type(:html) }
    end
  end

  describe "GET to edit" do
    context "with HTML request" do
      before do
        @mediafile = Factory(:mediafile, :account => @account)
        get :edit, :account_id => @account.id, :id => @mediafile.id
      end
    
      it { should assign_to(:mediafile).with(@mediafile) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end
    
    context "with XHR request" do
      before do
        @mediafile = Factory(:mediafile, :account => @account)
        xhr :get, :edit, :account_id => @account.id, :id => @mediafile.id
      end
    
      it { should assign_to(:mediafile).with(@mediafile) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
    end
  end
  
  describe "DELETE to destory" do
    before do
      @mediafile = Factory(:mediafile, :account => @account)
    end
    
    context "with HTML request" do
      before do
        delete :destroy, :account_id => @account.id, :id => @mediafile.id
      end
    
      it { should respond_with(:redirect) }
      it "should delete the article" do
        lambda { Article.find(@mediafile.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "with XHR request" do
      before do
        xhr :delete, :destroy, :account_id => @account.id, :id => @mediafile.id
      end
    
      it { should respond_with(:ok) }
      it { should set_the_flash.to('Media trashed') }
      it "should delete the article" do
        lambda { Article.find(@mediafile.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
