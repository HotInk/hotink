require 'spec_helper'

describe ActionsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)    
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to new with XHR request" do
    before do
      @articles = (1..3).collect{ Factory(:article, :account => @account) }
      @mediafiles = (1..3).collect{ Factory(:mediafile, :account => @account) }
      
      get :new, :name => "whatever_action", :content_types => ["article", "mediafile"], :mediafile_ids => @mediafiles.collect{|m| m.id }, :article_ids => @articles.collect{|a| a.id }
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should prepare an appropriate action" do
      should assign_to(:action).with_kind_of(Action)
      assigns(:action).name.should == "whatever_action"
      assigns(:action).content_types.should == ["article", "mediafile"]
    end
    it "should know which records to act on" do
      should assign_to(:records).with_kind_of(Hash)
      assigns(:records)["article"].should == @articles
      assigns(:records)["mediafile"].should == @mediafiles
    end
  end
  
  describe "POST to create" do
    describe "Delete action" do
      before do
        @mediafiles = (1..3).collect{ Factory(:mediafile, :account => @account) }
        post :create, :name => "delete", :content_types => ["mediafile"], :mediafile_ids => @mediafiles.collect{|a| a.id }
      end
      
      it { should respond_with(:redirect) }
      it "should delete the supplied mediafiles" do
        @mediafiles.each do |mediafile|
          lambda{ Mediafile.find(mediafile.id) }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
    
    describe "Publish articles action" do
      before do
        @articles = (1..3).collect{ Factory(:article, :account => @account) }
        post :create, :name => "publish", :content_types => ["article"], :article_ids => @articles.collect{|a| a.id }
      end
      
      it { should respond_with(:redirect) }
      it "should publish articles" do
        @articles.each do |article|
          article.reload.should be_published
        end
      end
    end
    
    describe "Schedule articles action" do
      before do
        @articles = (1..3).collect{ Factory(:article, :account => @account) }
        post :create, :name => "schedule", :content_types => ["article"], :article_ids => @articles.collect{|a| a.id }, :schedule =>{ "month"=>"3", "minute"=>"30", "hour"=>"15", "day"=>"3", "year"=>Date.today.year+1}
      end
      
      it { should respond_with(:redirect) }
      it "should scheduled articles" do
        @articles.each do |article|
          article.reload.should be_scheduled
        end
      end
    end
    
    describe "Unpublish articles action" do
      before do
        @articles = (1..3).collect{ Factory(:published_article, :account => @account) }
        post :create, :name => "unpublish", :content_types => ["article"], :article_ids => @articles.collect{|a| a.id }
      end
      
      it { should respond_with(:redirect) }
      it "should unpublish articles" do
        @articles.each do |article|
          article.reload.should_not be_published
        end
      end
    end
    
    describe "Add-issue articles action" do
      before do
        @issue = Factory(:issue, :account => @account)
        @articles = (1..3).collect{ Factory(:article, :account => @account) }
        post :create, :name => "add_issue", :content_types => ["article"], :article_ids => @articles.collect{|a| a.id }, :add_issue => { :issue => @issue.id }
      end
      
      it { should respond_with(:redirect) }
      it "should add articles to issue" do
        @articles.each do |article|
          article.issues.should include(@issue)
        end
      end
    end
    
    describe "Set-primary-section articles action" do
      before do
        @section = @account.categories.create(:name => "News")
        @articles = (1..3).collect{ Factory(:article, :account => @account) }
        post :create, :name => "set_primary_section", :content_types => ["article"], :article_ids => @articles.collect{|a| a.id }, :set_primary_section => { :section_id => @section.id }
      end
      
      it { should respond_with(:redirect) }
      it "should file articles into the appropriate section" do
        @articles.each do |article|
          article.reload.section.should == @section
        end
      end
    end
    
  end
  
end
