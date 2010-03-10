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
  
  it "should generate a standard name-email string for use as a select option" do
    @user.to_select_option_text.should == "#{@user.name} <#{@user.email}>"
  end
  
  it "should set a blank login to email username on create" do
    pending
    user = Factory.build(:user, :login => "")
    user.should be_new_record
    user.login.should == user.email.split('@').first
  end
end