require 'spec_helper'

describe Comment do
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should belong_to(:document) }
  it { should validate_presence_of(:document) }
  
  it { should ensure_length_of(:name).is_at_least(2).is_at_most(20) }
  it { should ensure_length_of(:body).is_at_least(5).is_at_most(2000) }
  
  it "should make sure email is a real email address" do
    should allow_value("chris@email.com").for(:email)
    should allow_value("chris-with_weird+address@anotherone.email.com").for(:email)
    should_not allow_value("chrisemail.com").for(:email)
    should_not allow_value("chris@email").for(:email)
  end
  
  it "should make sure an IP address is recorded for each comment" do
    should allow_value("0.0.0.0").for(:ip_address)
    should allow_value("192.1.0.222").for(:ip_address)
    should allow_value("100.111.101.222").for(:ip_address)
    should_not allow_value("").for(:ip_address)
    should_not allow_value("chris@email").for(:ip_address)
    should_not allow_value("192.1.2").for(:ip_address)
  end
end