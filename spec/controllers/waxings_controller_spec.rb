require 'spec_helper'

describe WaxingsController do
  before do
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to new" do
    context "with an HTML request" do
      before do
        @account = Factory(:account)
        @mediafiles = (1..3).collect{ Factory(:mediafile, :account => @account) }
        @attached_mediafile = Factory(:mediafile, :account => @account)
        @article = Factory(:article, :account => @account, :mediafiles => [@attached_mediafile])
        get :new, :account_id => @account.id, :article_id => @article.id
      end
      
      it "should build waxing" do
        should assign_to(:waxing).with_kind_of(Waxing)
        assigns(:waxing).document.should == @article
      end
      it { should assign_to(:mediafiles).with(@mediafiles) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end
  end
  
  describe "GET to edit with XHR request" do
    before do
      @waxing = Factory(:waxing)
      xhr :get, :edit, :account_id => @waxing.article.account.id, :id => @waxing.id
    end
    
    it { should assign_to(:waxing).with(@waxing) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
  end
  
  describe "POST to create" do
    describe "linking mediafiles to an article" do
      context "with an XHR request" do
        before do
          @article = Factory(:article)
          @mediafiles = (1..3).collect { Factory(:mediafile, :account => @article.account) }
          xhr :post, :create, :account_id =>  @article.account, :document_id => @article.id, :mediafile_ids => @mediafiles.collect { |m| m.id }
        end
        
        it { should set_the_flash.to("Media attached") }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:js) }
        it "should create waxings" do
          should assign_to(:document).with(@article)
          assigns(:document).mediafiles.should == @mediafiles
        end
      end
      
      context "with an HTML request" do
        before do
          @article = Factory(:article)
          @mediafiles = (1..3).collect { Factory(:mediafile, :account => @article.account) }
          post :create, :account_id =>  @article.account, :document_id => @article.id, :mediafile_ids => @mediafiles.collect { |m| m.id }
        end
        
        it { should assign_to(:document).with(@article) }
        it { should set_the_flash.to("Media attached") }
        it { should respond_with(:redirect) }
        it "should create waxings" do
          should assign_to(:document).with(@article)
          assigns(:document).mediafiles.should == @mediafiles
        end
      end
    end
    
    describe "linking mediafiles to an entry" do
      before do
        @entry = Factory(:entry)
        @mediafiles = (1..3).collect { Factory(:mediafile, :account => @entry.account) }
        post :create, :account_id =>  @entry.account, :document_id => @entry.id, :mediafile_ids => @mediafiles.collect { |m| m.id }
      end
      
      it { should assign_to(:document).with(@entry) }
      it { should set_the_flash.to("Media attached") }
      it { should respond_with(:redirect) }
      it "should create waxings" do
        should assign_to(:document).with(@entry)
        assigns(:document).mediafiles.should == @mediafiles
      end  
    end
  end
  
  describe "PUT to update" do
    before do
      @waxing = Factory(:waxing, :caption => "")
      xhr :put, :update, :account_id => @waxing.document.account.id, :id => @waxing.id, :waxing => { :caption => "Wow, a caption." }
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should update waxing" do
      should assign_to(:waxing).with(@waxing)
      assigns(:waxing).caption.should == "Wow, a caption."
    end
  end
  
  describe "DELETE to destroy with XHR request" do
    before do
      @waxing = Factory(:waxing)
      xhr :delete, :destroy, :account_id => @waxing.document.account.id, :id => @waxing.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it { should set_the_flash.to('Media detached') }
    it "should delete waxing" do
      should assign_to(:waxing).with(@waxing)
      lambda{ Waxing.find(@waxing.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
end
