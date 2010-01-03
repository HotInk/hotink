require 'spec_helper'

describe Cupwire do
  include Rack::Test::Methods
  
  before do
    @account = Factory(:account)      
    Account.stub!(:find).and_return(@account)
  end
  
  def app
    Cupwire
  end
end