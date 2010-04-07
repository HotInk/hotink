require 'spec_helper'

describe EntriesController do
  before do
    @account = Factory(:account)
    @blog = Factory(:blog, :account => @account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to new" do
    before do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
    
      get :new, :account_id => @account.id, :blog_id => @blog.id
    end
    
    it { should assign_to(:blog).with(@blog) }    
    it { should assign_to(:entry).with_kind_of(Entry) }
    it { should respond_with(:redirect) }
    it "should assign the correct entry owner" do
      assigns(:entry).owner.should eql(@user)
    end
  end
  
  describe "GET to edit" do
    before do
      @entry = Factory(:entry, :blog => @blog, :account => @account)
    end
    
    context "by entry's owner" do
      before do
        @user = Factory(:user)
        @entry.owner = @user
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should assign_to(:blog).with(@blog) }    
      it { should assign_to(:entry).with(@entry) }
      it { should respond_with(:success) }
    end
    
    context "by administrator" do
      before do
        @user = Factory(:user)
        @user.has_role("admin")
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should assign_to(:blog).with(@blog) }    
      it { should assign_to(:entry).with(@entry) }
      it { should respond_with(:success) }
    end

    context "by account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should assign_to(:blog).with(@blog) }    
      it { should assign_to(:entry).with(@entry) }
      it { should respond_with(:success) }
    end

    context "by editor of blog" do
      before do
        @user = Factory(:user)
        @user.has_role("editor", @blog)
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should assign_to(:blog).with(@blog) }    
      it { should assign_to(:entry).with(@entry) }
      it { should respond_with(:success) }
    end
    
    context "by blog contributor who's not owner of entry" do
      before do
        @user = Factory(:user)
        @user.has_role("contributor", @blog)
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should respond_with(:redirect) }
    end
    
    context "by user prohibited from editing entry" do
      before do
        get :edit, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should respond_with(:redirect) }
    end
  end
   
  describe "GET to show" do
    before do
      @entry = Factory(:entry, :blog => @blog, :account => @account)
      get :show, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:entry).with(@entry) }
  end
  
  describe "PUT to update" do
    before do
      @entry = Factory(:entry, :blog => @blog, :account => @account)    
    end
    
    context "as entry's owner" do
      before do
        @user = Factory(:user)
        @entry.owner = @user
        controller.stub!(:current_user).and_return(@user)
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
         put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "Published" }
        end
      
        it "should publish the entry" do
          @entry.reload.should be_published
        end
      end
    
      describe "scheduling entry" do
        before do        
          schedule = { :year => "2015", :month => "3", :day => "4", :hour => "12", :minute => "35" }
          put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "Published", :schedule => schedule }
        end
      
        it "should schedule the entry" do
          @entry.reload.should be_scheduled
        end
      end
    
      describe "unpublishing entry" do
        before do        
          @entry.publish
          put :update, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id, :entry => { :status => "" }
        end
      
        it "should unpublished the entry" do
          @entry.reload.should be_draft
        end
      end
    end
  end
  
  describe "DELETE to destory" do
    before do
      @entry = Factory(:entry, :blog => @blog, :account => @account)
    end    
  
    context "with XHR request" do
      before do
        xhr :delete, :destroy, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it { should render_template('destroy') }
      it "should delete the entry" do
        lambda { Entry.find(@entry.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end      
    end
    
    context "with HTML request" do
      before do
        delete :destroy, :account_id => @account.id, :blog_id => @blog.id, :id => @entry.id
      end
      
      it { should respond_with(:redirect) }
      it "should delete the entry" do
        lambda { Entry.find(@entry.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

end
