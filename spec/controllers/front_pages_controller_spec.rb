require 'spec_helper'

describe FrontPagesController do
  before do
    @account = Factory(:account)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET to edit" do
    before do
      @articles = (1..5).collect{ Factory(:published_article, :account => @account) }
    end
    
    context "with lead articles" do
      before do
        @lead_articles = @articles[0..2]
        @account.update_attribute :lead_article_ids, @lead_articles.collect { |a| a.id }
        get :edit, :account_id => @account.id
      end
    
      it { should respond_with(:success) }
      it { should render_with_layout(:hotink) }
      it { should assign_to(:articles).with(@articles) }
      it { should assign_to(:lead_articles).with(@lead_articles) }
    end
    
    context "without lead articles" do
      before do
        @account.lead_article_ids = []
        get :edit, :account_id => @account.id
      end
    
      it { should respond_with(:success) }
      it { should assign_to(:articles).with(@articles) }
      it { should assign_to(:lead_articles).with([]) }
    end
  end
  
  describe "PUT to update" do
    context "with a valid array of lead article IDs" do
      before do
        put :update, :account_id => @account.id, :lead_article_ids => [1,2,5,4,3]
      end
      
      it { should respond_with(:redirect) }
      it "should update settings" do
        @account.reload.lead_article_ids.should eql([1,2,5,4,3])
      end
    end
    
    context "without lead article ids" do
      before do
        @account.update_attribute :lead_article_ids, [1,2,5,4,3]
        put :update, :account_id => @account.id
      end
      
      it { should respond_with(:redirect) }
      it "should remove all elad articles" do
        @account.reload.lead_article_ids.should eql(nil)
      end
    end
    
    context "with front page template" do
      before do
        @design = Factory(:design, :account => @account)
        @account.update_attribute :current_design, @design
        
        @template = Factory(:front_page_template, :design => @design)        
        @other_template = Factory(:front_page_template, :design => @design)

        put :update, :account_id => @account.id, :current_front_page_template_id => @other_template.id
      end

      it { should respond_with(:redirect) }
      it "should update settings" do
        @design.reload.current_front_page_template_id.should eql(@other_template.id)
      end
    end
  end

end
