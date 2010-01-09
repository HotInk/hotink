require 'spec_helper'

describe User do
  before(:each) do
    @user = Factory(:user)
  end
    
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  
  it "should find when given a login or an email" do
    User.find_by_login_or_email(@user.login).should == @user
    User.find_by_login_or_email(@user.email).should == @user
  end
  
end