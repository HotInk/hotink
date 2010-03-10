require 'spec_helper'

describe Cupwire do
  include Rack::Test::Methods
  
  before do
    @account = Factory(:account)      
    Account.stub!(:find).and_return(@account)
    Settings.stub!(:cup_wire_account).and_return(@account.id)
  end
  
  def app
    Cupwire
  end
end