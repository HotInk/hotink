require 'spec_helper'

describe PublicFrontPagesController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "GET to show" do 
    before do
      @lead_articles = (1..5).collect{ Factory(:published_article, :account => @account) }
      @account.update_attribute :lead_article_ids, @lead_articles.collect{ |a| a.id }
    end
    
    context "with a current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.stub!(:current_design).and_return(@design)
      end
        
      context "with a current front page template" do
        before do
          @template = @design.front_page_templates.create(:name => "A template")
          @design.update_attribute :current_front_page_template, @template
        end
        
        context "viewing with current design" do
          before do
            get :show, :account_id => @account.id
          end
      
          it { should respond_with(:success) }
          it { should assign_to(:front_page_template).with(@template) }
          it { should assign_to(:design).with(@design) }
        end
        
        describe "viewing with alternate design" do
          before do
            @alternate_design = Factory(:design, :account => @account)
          end
            
          context "as qualified user" do
             before do
               @current_user = Factory(:user)
               @current_user.promote_to_admin
               controller.stub!(:current_user).and_return(@current_user)
               
               get :show, :account_id => @account.id, :design_id => @alternate_design.id
             end
             
             it { should assign_to(:design).with(@alternate_design) }
             it { should assign_to(:front_page_template).with(@alternate_design.front_page_templates.first) }
           end
           
           context "as unqualified user" do
             before do
               get :show, :account_id => @account.id, :design_id => @alternate_design.id
             end
             
             it { should assign_to(:design).with(@design) }
           end
         end
      end
    
      context "with no specified front page template" do
        before do
          @design.update_attribute :current_front_page_template_id, nil
        
          get :show, :account_id => @account.id
        end
      
        it { should respond_with(:success) }
        it { should assign_to(:front_page_template).with(@design.front_page_templates.first) }
      end
    end
    
    context "without a current design" do
      before do
        @account.update_attribute(:current_design_id, nil)
        get :show, :account_id => @account.id
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end

  describe "GET to preview" do
    context "for qualified_user" do
      before do
        @current_user = Factory(:user)
        @current_user.promote_to_admin
        controller.stub!(:current_user).and_return(@current_user)
        
        @lead_articles = (1..5).collect{ Factory(:published_article, :account => @account) }
      
        @design = Factory(:design, :account => @account)
        @template = @design.front_page_templates.create(:name => "A template")
        @account.update_attribute :current_design_id, @design.id
      
        get :preview, :account_id => @account.id, :preview_front_page_template_id => @template.id, :lead_article_ids => @lead_articles.collect{ |a| a.id }
      end
    
      it { should respond_with(:success) }
      it { should assign_to(:front_page_template).with(@template) }
      it { should assign_to(:lead_articles).with(@lead_articles) }
      it { should assign_to(:design).with(@design) }    
    end
    
    context "for unqualified user" do
      before do
        @current_user = Factory(:user)
        controller.stub!(:current_user).and_return(@current_user)
        
        get :preview, :account_id => @account.id
      end
      
      it { should respond_with(:redirect) }
    end 
  end

end
