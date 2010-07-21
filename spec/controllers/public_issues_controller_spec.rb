require 'spec_helper'

describe PublicIssuesController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "GET to show" do
     before do
       @issue = Factory(:issue, :account => @account)
     end

     context "with a current design" do
       before do
         @design = Factory(:design, :account => @account)
         @account.stub!(:current_design).and_return(@design)

         @template = mock('issue template')
         @design.stub!(:issue_template).and_return(@template)

         @content_drop = ContentDrop.new(@account)
         @site_drop = SiteDrop.new(@account)
         SiteDrop.stub!(:new).and_return(@site_drop)
         ContentDrop.stub!(:new).and_return(@content_drop)
       end
       
       context "viewing with current design" do
         before do
           @issue_drop = IssueDrop.new(@blog)
           IssueDrop.stub!(:new).and_return(@issue_drop)

           @template.should_receive(:render).with({ 'issue' => @issue_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design } )

           get :show, :account_id => @account.id, :id => @issue.id
         end

         it { should respond_with(:success) }
         it { should assign_to(:issue).with(@issue) }
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

              get :show, :account_id => @account.id, :id => @issue.id, :design_id => @alternate_design.id
            end

            it { should assign_to(:design).with(@alternate_design) }
         end

         context "as unqualified user" do
            before do
              @template.should_receive(:render)
              get :show, :account_id => @account.id, :id => @issue.id, :design_id => @alternate_design.id
            end

            it { should assign_to(:design).with(@design) }
          end
       end
     end
     
     context "without a current design" do
       before do
         @account.stub!(:current_design).and_return(nil)
         get :show, :account_id => @account.id, :id => @issue.id
       end

       it { should respond_with(:service_unavailable) }
     end
  end

  describe "GET to index" do
    before do
      @issues = (1..3).collect{ Factory(:issue, :account => @account) }
    end
    
    context "with a current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.stub!(:current_design).and_return(@design)

        @template = mock('issue index template')
        @design.stub!(:issue_index_template).and_return(@template)
        
        @content_drop = ContentDrop.new(@account)
        @site_drop = SiteDrop.new(@account)
        SiteDrop.stub!(:new).and_return(@site_drop)
        ContentDrop.stub!(:new).and_return(@content_drop)
      end
      
      context "viewing with current design" do
        before do
          @template.should_receive(:render)

          get :index, :account_id => @account.id
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:issues).with(@issues) }
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
             
             get :index, :account_id => @account.id, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@alternate_design) }
        end
         
        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             get :index, :account_id => @account.id, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@design) }
        end
      end
    end
    
    context "without a current design" do
      before do
        @account.stub!(:current_design).and_return(nil)
        get :index, :account_id => @account.id
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end
end