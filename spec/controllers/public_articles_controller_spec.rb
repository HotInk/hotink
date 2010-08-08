require 'spec_helper'

describe PublicArticlesController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "GET to show" do    
    context "with a current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.stub!(:current_design).and_return(@design)
          
        @template = mock('article template')
        @design.stub!(:article_template).and_return(@template)
        
        @content_drop = ContentDrop.new(@account)
        @site_drop = SiteDrop.new(@account)
        ContentDrop.stub!(:new).and_return(@content_drop)
        SiteDrop.stub!(:new).and_return(@site_drop)
      end
      
      context "viewing with current design" do
        context "for a published article" do
          before do
            @article = Factory(:published_article, :account => @account)
            @article_drop = ArticleDrop.new(@article)
            ArticleDrop.stub!(:new).and_return(@article_drop)
            @template.should_receive(:render).with({ 'article' => @article_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design, :form_authenticity_token => controller.send(:form_authenticity_token) } )

            get :show, :account_id => @account.id, :id => @article.id
          end
          
          it { should respond_with(:success) }
          it { should assign_to(:article).with(@article) }
          it { should assign_to(:design).with(@design) }
        end

        describe "unpublished article preview" do
          before do
            @article = Factory(:article, :account => @account)        
          end

          context "for a user with read access" do
            before do
              @current_user = Factory(:user)
              @current_user.promote_to_admin
              controller.stub!(:current_user).and_return(@current_user)

              @article_drop = ArticleDrop.new(@article)
              ArticleDrop.stub!(:new).and_return(@article_drop)
              @template.should_receive(:render).with({ 'article' => @article_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design, :form_authenticity_token => controller.send(:form_authenticity_token) } )

              get :show, :account_id => @account.id, :id => @article.id
            end

            it { should respond_with(:success) }
            it { should assign_to(:article).with(@article) }
            it { should assign_to(:design).with(@design) }
          end

          context "for a non-user" do
            before do
              get :show, :id => @article.id 
            end

            it { should respond_with(:not_found) }
          end
        end
      end
    
      describe "when not found" do
        before do
          @template = mock('not found template')
          @design.stub!(:not_found_template).and_return(@template)
          @template.should_receive(:render)
          get :show, :id => "no-record"
        end

        it { should respond_with(:not_found) }
        it { should assign_to(:design).with(@design) }
      end
      
      describe "viewing with alternate design" do
        before do
          @article = Factory(:published_article, :account => @account)
          @alternate_design = Factory(:design, :account => @account)
        end
          
        context "as qualified user" do
           before do
             @current_user = Factory(:user)
             @current_user.promote_to_admin
             controller.stub!(:current_user).and_return(@current_user)
             
             get :show, :account_id => @account.id, :id => @article.id, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@alternate_design) }
        end
         
        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             get :show, :account_id => @account.id, :id => @article.id, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@design) }
         end
      end
    end
      
   context "without a current design" do
      before do
        @article = Factory(:published_article, :account => @account)
        @account.stub!(:current_design_id).and_return(nil)
        get :show, :account_id => @account.id, :id => @article.id
      end

      it { should respond_with(:service_unavailable) }
   end
  end
end
