require 'spec_helper'

describe EntriesController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to new" do
    before do
      @blog = Factory(:blog, :account => @account)
      get :new, :account_id => @account.id, :blog_id => @blog.id
    end
    
    it { should assign_to(:blog).with(@blog) }    
    it { should assign_to(:entry).with_kind_of(Entry) }
    it { should respond_with(:redirect) }
  end
  
  describe "GET to edit" do
    before do
      @blog = Factory(:blog, :account => @account)
      @entry = Factory(:entry, :blogs => [@blog], :account => @account)
      get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
    end
    
    it { should assign_to(:blog).with(@blog) }    
    it { should assign_to(:entry).with(@entry) }
    it { should respond_with(:success) }
  end
  
  describe "PUT to update" do
    before do
      @blog = Factory(:blog, :account => @account)
      @entry = Factory(:entry, :blogs => [@blog], :account => @account)    
    end
    
    context "with valid parameters" do
      context "as an HTML request" do
        before do
          put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :title => "Whoa there. Title time." }
        end

        it { should assign_to(:blog).with(@blog) }    
        it { should assign_to(:entry).with(@entry) }
        it { should set_the_flash.to("Entry saved") }
        it { should respond_with(:redirect) }
        it "should update the article" do
          @entry.reload.title.should == "Whoa there. Title time."
        end
      end

      context "as an XHR request" do
        before do
          xhr :put, :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :title => "Whoa there. Title time." }
        end

        it { should assign_to(:blog).with(@blog) }    
        it { should assign_to(:entry).with(@entry) }
        it { should set_the_flash.to("Entry saved") }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:js) }
        it "should update the article" do
          @entry.reload.title.should == "Whoa there. Title time."
        end
      end
    end
    
    context "with invalid parameters" do
      before do
        put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :account => nil }
      end

      it { should assign_to(:blog).with(@blog) }    
      it { should assign_to(:entry).with(@entry) }
      it { should respond_with(:bad_request) }
      it { should render_template(:edit) }
    end
    
    describe "publishing entry" do
      before do
        @user = Factory(:user)
        @user.has_role("contributor", @blog)
        controller.stub!(:current_user).and_return(@user)
        
       put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "Published" }
      end
      
      it "should publish the entry" do
        @entry.reload.should be_published
      end
    end
    
    describe "scheduling entry" do
      before do
        @user = Factory(:user)
        @user.has_role("contributor", @blog)
        controller.stub!(:current_user).and_return(@user)
        
        schedule = { :year => "2015", :month => "3", :day => "4", :hour => "12", :minute => "35" }
        put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "Published", :schedule => schedule }
      end
      
      it "should schedule the entry" do
        @entry.reload.should be_scheduled
      end
    end
    
    describe "unpublishing entry" do
      before do
        @user = Factory(:user)
        @user.has_role("contributor", @blog)
        controller.stub!(:current_user).and_return(@user)
        
        @entry.publish
        put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "" }
      end
      
      it "should unpublished the entry" do
        @entry.reload.should be_draft
      end
    end
  end
  
  
  describe "DELETE to destory" do
    before do
      @blog = Factory(:blog, :account => @account)
      @entry = Factory(:entry, :blogs => [@blog], :account => @account)
      delete :destroy, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
    end

    it { should respond_with(:redirect) }
    it "should delete the article" do
      lambda { Entry.find(@entry.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
