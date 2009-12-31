require 'spec_helper'

describe SsoConsumer do
  subject { Factory(:sso_consumer) }
  
  it { should validate_uniqueness_of(:url).case_insensitive }
  
  it "should verify whether a submitted url represents a valid consumer" do
    consumer = Factory(:sso_consumer)
    SsoConsumer.allowed?(consumer.url).should be_true
    SsoConsumer.allowed?("http://notarealcinsumerhost.com").should be_false
  end
end
