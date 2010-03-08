require 'spec_helper'

describe AppsController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end

  describe "GET to show" do
    before do
      @sso_consumer = Factory(:sso_consumer)
      get :show, :account_id => @account.id, :id => @sso_consumer.id
    end
    
    it { should render_with_layout(:apps) }
    it { should assign_to(:app).with(@sso_consumer) }
    it { should assign_to(:iframe_url).with("#{@sso_consumer.url.split('/sso/login')[0]}/accounts/#{@account.id}#{@sso_consumer.landing_url}") }
  end
end
