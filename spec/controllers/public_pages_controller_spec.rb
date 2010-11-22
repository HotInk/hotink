require 'spec_helper'

describe PublicPagesController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
    describe "GET to show" do
      context "with page using no template" do
        before do
          @page = Factory(:page, :account => @account)
        
          get :show, :account_id => @account.id, :id => @page.name
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:page).with(@page) }
        it "should not load template" do
          PageTemplate.should_not_receive(:find)
        end
      end
      
      context "with page using template" do
        before do
          @page_template = Factory(:page_template)
          @page = Factory(:page, :template => @page_template, :account => @account)
          PageTemplate.stub!(:find).and_return(@page_template)
          
          @content_drop = ContentDrop.new(@account)
          @site_drop = SiteDrop.new(@account)
          SiteDrop.stub!(:new).and_return(@site_drop)
          ContentDrop.stub!(:new).and_return(@content_drop)
          
          @page_template.should_receive(:render)
          
          get :show, :account_id => @account.id, :id => @page.name
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:page).with(@page) }
      end
    end

end
