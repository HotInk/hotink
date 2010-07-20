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
  
    context "relative to document" do
      before do
        @article = Factory(:article, :account => @account)
        xhr :get, :new, :account_id => @account.id, :document_id => @article.id
      end

      it { should assign_to(:mediafile).with_kind_of(Mediafile) }
      it { should assign_to(:document).with_kind_of(Document) }
      it { should respond_with_content_type(:html) }
      it { should_not render_with_layout(:hotink) }
    end
    
    context "without document" do
      before do
        get :new, :account_id => @account.id
      end
      
      it { should assign_to(:mediafile).with_kind_of(Mediafile) }
      it { should_not assign_to(:document) }
      it { should respond_with_content_type(:html) }
      it { should render_with_layout(:hotink) }
    end
  end

  describe "POST to create" do
    context "with valid HTML request and a Mediafile" do
      before do
        post :create, :account_id => @account.id, :mediafile => { :file => fixture_file_upload('/test-txt.txt') }
      end
      it { should assign_to(:mediafile).with_kind_of(Mediafile) }
      it { should respond_with(:redirect) }
    end
    
    context "with invalid HTML request" do
      before do
        post :create, :account_id => @account.id, :mediafile => { :file => "heheheheh" }
      end
      
      it { should respond_with(:bad_request) }
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
  
  describe "PUT to update" do
    context "with valid HTML request" do
      context "when updating mediafile" do
        before do
          @mediafile = Factory(:mediafile, :account => @account)
          put :update, :account_id => @account.id, :id => @mediafile.id, :mediafile => { :title => "Some mediafile" }
        end
      
        it { should assign_to(:mediafile).with(@mediafile) }
        it { should respond_with(:redirect) }
        it "should update the mediafile" do
          @mediafile.reload.title.should == "Some mediafile"
        end
      end
      
      context "when updating image" do
        before do
          @mediafile = Factory(:image, :account => @account)
          put :update, :account_id => @account.id, :id => @mediafile.id, :image => { :title => "Some mediafile" }
        end
      
        it { should assign_to(:mediafile).with(@mediafile) }
        it { should respond_with(:redirect) }
        it "should update the mediafile" do
          @mediafile.reload.title.should == "Some mediafile"
        end
      end
      
      context "when updating audiofile" do
        before do
          @mediafile = Factory(:audiofile, :account => @account)
          put :update, :account_id => @account.id, :id => @mediafile.id, :audiofile => { :title => "Some mediafile" }
        end
      
        it { should assign_to(:mediafile).with(@mediafile) }
        it { should respond_with(:redirect) }
        it "should update the mediafile" do
          @mediafile.reload.title.should == "Some mediafile"
        end
      end
    end
    
    context "with valid XHR request" do
      before do
        @mediafile = Factory(:mediafile, :account => @account)
        xhr :put, :update, :account_id => @account.id, :id => @mediafile.id, :mediafile => { :title => "Some mediafile" }
      end
      
      it { should assign_to(:mediafile).with(@mediafile) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it "should update the mediafile" do
        @mediafile.reload.title.should == "Some mediafile"
      end
    end
    
    context "with invalid request" do
      before do
         @mediafile = Factory(:mediafile, :account => @account)
         put :update, :account_id => @account.id, :id => @mediafile.id, :mediafile => { :account_id => "" }
       end

       it { should assign_to(:mediafile).with(@mediafile) }
       it { should respond_with(:bad_request) }
       it { should render_template(:edit) }
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
      it "should delete the mediafile" do
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
        lambda { Mediafile.find(@mediafile.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
