require 'spec_helper'

describe TagsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to new with XHR request" do
    before do
      @article = Factory(:article, :account => @account) 
      xhr :get, :new, :account_id => @article.account.id, :article_id => @article.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it { should render_template('new') }
  end
end
