require 'spec_helper'

describe ArticlesController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to index" do
    context "with no articles" do
      before do
        get :index
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
      it { should render_with_layout(:hotink) }
      it { should assign_to(:articles).with([]) }
    end
    
    context "with draft, scheduled and published articles" do
       before do
         @drafts = (1..3).collect{ |n| Factory(:draft_article, :updated_at => n.days.ago, :account => @account ) }
         @scheduled = (1..3).collect{ |n| Factory(:scheduled_article, :published_at => (Time.now + 1.day - n.minutes), :account => @account ) } 
         @published = (1..3).collect{ |n| Factory(:published_article, :published_at => (Time.now - 1.day - n.minutes), :account => @account) }
         get :index, :account_id => @account.id
       end
       
       it { should respond_with(:success) }

       it "should paginate published articles" do
          should assign_to(:articles).with(@drafts + @scheduled + @published)
          assigns(:articles).should be_kind_of(WillPaginate::Collection)
       end      
    end
  end

  describe "GET to search" do
    before do
      @articles = (1..2).collect{ Factory(:published_article, :account => @account) }
    end
    
    context "with a query" do
      before do
        @searched_articles = [Factory(:published_article, :title => "Experimental testing", :account => @account), Factory(:published_article, :bodytext => "Experimental testing", :account => @account)]
        Article.should_receive(:search).and_return(@searched_articles)
        get :search, :q => "Experimental testing"
      end
    
       it { should respond_with(:success) }
       it { should respond_with_content_type(:html) }
       it { should render_template(:search) }
       it { should render_with_layout(:hotink) }
       it { should assign_to(:search_query).with("Experimental testing") }
       it { should assign_to(:articles).with(@searched_articles) }
    end
    
    context "with no query" do
      before do
        get :search, :account_id => @account.id
      end
      
      it { should respond_with(:success) }
      it { should render_template(:search) }
      it { should assign_to(:articles).with([]) }
    end
  end

  describe "GET to show" do
    before do
      @article = Factory(:article, :account => @account)
      get :show, :id => @article.id
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:article).with(@article) }
  end
  
  describe "GET to edit" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by article's owner" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
        get :edit, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by administrator" do
      before do
        @user = Factory(:user)
        @user.has_role("admin")
        controller.stub!(:current_user).and_return(@user)
        get :edit, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        get :edit, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by user prohibited from editing article" do
      before do
        get :edit, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
    end
  end

  describe "GET to new" do
    before do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      
      get :new
    end
    
    it { should assign_to(:article).with_kind_of(Article) }
    it { should respond_with(:redirect) }
    it "should assign the correct article owner" do
      assigns(:article).owner.should eql(@user)
    end
  end
  
  describe "PUT to update" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by user prohibited from updating article" do
      before do
        put :update, :id => @article.id, :article => { :title => "Whoa there. Title time." }
      end
      
      it { should assign_to(:article).with(@article) }
      it { should respond_with(:redirect) }
    end
    
    context "by article's owner" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
      end
      
      context "with valid parameters" do
        context "as an HTML request" do
          before do
            put :update, :id => @article.id, :article => { :title => "Whoa there. Title time." }
          end

          it { should assign_to(:article).with(@article) }
          it { should set_the_flash.to("Article saved") }
          it { should respond_with(:redirect) }
          it "should update the article" do
            @article.reload.title.should == "Whoa there. Title time."
          end
        end
      end
      
      context "with invalid parameters" do
        before do
          put :update, :id => @article.id, :article => { :account => nil }
        end

        it { should assign_to(:article).with(@article) }
        it { should respond_with(:bad_request) }
        it { should render_template(:edit) }
      end
    end
    
    describe "publishing article" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        
        put :update, :id => @article.id, :article => { :status => "Published" }
      end
      
      it "should publish the article" do
        @article.reload.should be_published
      end
    end
    
    describe "scheduling article" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        
        schedule = { :year => "2015", :month => "3", :day => "4", :hour => "12", :minute => "35" }
        put :update, :id => @article.id, :article => { :status => "Published", :schedule => schedule }
      end
      
      it "should schedule the article" do
        @article.reload.should be_scheduled
      end
    end
    
    describe "unpublishing article" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
        
        @article.publish
        put :update, :id => @article.id, :article => { :status => "" }
      end
      
      it "should unpublished the article" do
        @article.reload.should be_draft
      end
    end
    
    describe "categories" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
      end
      
      describe "attaching categories" do
        before do
          @category1 = Factory(:category)
          @category2 = Factory(:category)
          put :update, :id => @article.id, :article => { :category_ids => [@category1.id, @category2.id] }
        end
      
        it "should attach categories" do
          @article.reload.categories.should include(@category1)
          @article.categories.should include(@category2)
        end
      end
    
      describe "detaching category" do
        before do       
          @category = Factory(:category)
          @article.categories << @category
          put :update,  :id => @article.id, :article => { :category_ids => [] }
        end
      
        it "should attach category" do
          @article.reload.categories.should_not include(@category)
        end
      end
    end
    
    describe "signing off on article" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
        
        put :update, :id => @article.id, :article => { :status => "Awaiting attention" }
      end
      
      it "should apply current user's sign off the article" do
        @article.should be_signed_off_by(@user)
        @article.reload.should be_awaiting_attention
      end
    end
    
    describe "revoking signing off on article" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
        
        put :update, :id => @article.id, :article => { :status => "Awaiting attention" }
        put :update, :id => @article.id, :article => { :revoke_sign_off => "true" }
      end
      
      it "should revoke current user's sign off the article" do
        @article.should_not be_signed_off_by(@user)
      end
    end
  end

  describe "DELETE to destory" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        delete :destroy, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
      it "should delete the article" do
        lambda { Article.find(@article.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "by user prohibited from deleting article" do
      before do
        delete :destroy, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
      it "should not delete the article" do
        Article.find(@article.id).should == @article
      end
    end
  end
end
