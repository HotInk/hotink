require 'spec_helper'

describe Account do
  before(:each) do
    @account = Account.create!(Factory.attributes_for(:account))
  end
  
  it { should validate_presence_of(:time_zone).with_message(/must indicate its preferred time zone/) }
  it { should validate_presence_of(:name).with_message(/must have a name/) }
  it { should validate_uniqueness_of(:name).with_message(/must be unique/) }
  
  it { should have_many(:articles) }
  it { should have_many(:email_templates) }
  it { should have_many(:blogs) }
  
  it { should have_one(:membership) }
  
  it "should keep track of users invited to have access to the account" do
    should have_many(:user_invitations)
  end

  it "should know a human-readable list of its managers" do
    managers = (1..3).collect{ Factory(:user) }
    @account.managers_list.should == nil
    
    managers[0].has_role('manager', @account)
    @account.managers_list.should == "#{managers[0].name} <#{managers[0].email}>"
    
    managers[1].has_role('manager', @account)
    @account.managers_list.should == "#{managers[0].name} <#{managers[0].email}> and #{managers[1].name} <#{managers[1].email}>"
    
    
    managers[2].has_role('manager', @account)
    @account.managers_list.should == "#{managers[0].name} <#{managers[0].email}>, #{managers[1].name} <#{managers[1].email}> and #{managers[2].name} <#{managers[2].email}>"
  end
  
  it "should update convert its image settings from HTML-form friendly format into ImageMagick friendly format" do
    @account.image_settings = {"small"=>{:height=>"", :width=>"218"}, "medium"=>{:height=>"458", :width=>""}, "thumb"=>{:height=>"190", :width=>"100"}}
    @account.settings["image"]["small"].should ==  ["218>", "jpg"]
    @account.settings["image"]["medium"].should ==  ["x458>", "jpg"]
    @account.settings["image"]["thumb"].should ==  ["100x190>", "jpg"]
  end
  
  describe "role management" do
    before do
      @user = Factory(:user)
    end
  
    it "should promote user on account, if applicable" do
      @user.has_role?('staff', @account).should be_false
      
      @account.promote(@user)
      @user.has_role?('staff', @account).should be_true
      
      @account.promote(@user)      
      @user.has_role?('editor', @account).should be_true
      
      @account.promote(@user)      
      @user.has_role?('manager', @account).should be_true
      @user.has_role?('editor', @account).should be_false
      
      @user.has_role?('staff', @account).should be_true
    end
    
    it "should demote user on account, if applicable" do
      @user.has_role('staff', @account)
      @user.has_role('manager', @account)
      
      @account.demote(@user)
      @user.has_role?('editor', @account).should be_true
      @user.has_role?('manager', @account).should be_false
      
      @account.demote(@user)
      @user.has_role?('editor', @account).should be_false
      @user.has_role?('staff', @account).should be_true
      
      @account.demote(@user)
      @user.has_role?('staff', @account).should be_false
    end
  end
  
end