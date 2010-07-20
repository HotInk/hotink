require 'spec_helper'

describe DashboardsController do
  before do
    @account = Factory(:account)
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
                    
  describe "GET to show" do
    before do
      @design = Factory(:design, :account => @account)
      @account.update_attribute :current_design_id, @design.id
      @articles = (1..5).collect{ Factory(:published_article, :account => @account) }
    end
    
    context "with lead articles" do
      before do
        @lead_articles = @articles[0..2]
        @account.update_attribute :lead_article_ids, @lead_articles.collect { |a| a.id }
        get :show, :account_id => @account.id
      end
    
      it { should respond_with(:success) }
      it { should render_with_layout(:hotink) }
      it { should assign_to(:current_front_page_template).with(@design.front_page_templates.first) }
      it { should assign_to(:lead_articles).with(@lead_articles) }
    end
    
    context "without lead articles" do
      before do
        @account.update_attribute :lead_article_ids, []
        get :show, :account_id => @account.id
      end
    
      it { should assign_to(:lead_articles).with([]) }
    end
    
    context "with specified front page template" do
      before do
        @account.update_attribute :lead_article_ids, []
        @front_page_template = Factory(:front_page_template, :design => @design)
        @design.update_attribute :current_front_page_template_id, @front_page_template.id
        get :show, :account_id => @account.id
      end
    
      it { should assign_to(:current_front_page_template).with(@front_page_template) }
    end
    
    context "with recently updated lists" do
      before do
        @lists = (1..2).collect { Factory(:list, :account => @account)  }
        get :show, :account_id => @account.id
      end

      it { should assign_to(:lists).with(@lists) }
    end
    
    context "with blogs" do
      before do
        @blogs = (1..2).collect { Factory(:blog, :account => @account, :status => true)  } 
        @inactive_blogs = (1..2).collect { Factory(:blog, :account => @account, :status => false)  }
        @other_account_blogs = (1..2).collect { Factory(:blog)  }
        
        (@blogs + @inactive_blogs + @other_account_blogs).each do |blog|
          @current_user.has_role "contributor", blog
        end
        
        get :show, :account_id => @account.id
      end

      it { should assign_to(:blogs).with(@blogs) }
    end
  end
  
end
