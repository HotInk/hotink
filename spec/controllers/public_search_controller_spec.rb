require 'spec_helper'

describe PublicSearchController do
  
  describe "GET to show" do
    before do
      @account = Factory(:account)
      Account.stub!(:find).and_return(@account)
    end
    
    context "with a current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.stub!(:current_design).and_return(@design)

        @template = mock('search results template')
        @design.stub!(:search_results_template).and_return(@template)
      end
      
      context "viewing with current design" do
        before do
          @template.should_receive(:render)
          Article.should_receive(:search).and_return([])
          get :show, :account_id => @account.id, :q => "search test"
        end

        it { should respond_with(:success) }
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
             Article.should_receive(:search).and_return([])

             get :show, :account_id => @account.id, :q => "search test", :design_id => @alternate_design.id
           end

           it { should assign_to(:design).with(@alternate_design) }
        end

        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             Article.should_receive(:search).and_return([])
             
             get :show, :account_id => @account.id, :q => "search test", :design_id => @alternate_design.id
           end

           it { should assign_to(:design).with(@design) }
         end
      end
    end
    
    context "without a current design" do
      before do
        @account.stub!(:current_design).and_return(nil)
        get :show, :account_id => @account.id
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end

end
