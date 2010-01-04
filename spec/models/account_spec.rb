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
    should have_many(:invitations)
  end
  
  it "should find accounts in order of most recently published articles" do
    pending
    recent_account = Factory(:account)
    less_recent_account = Factory(:account)
    recent_article = Factory(:published_article, :title => "Most recent", :account => recent_account)
    less_recent_article = Factory(:published_article, :title => "Less recent", :published_at => 1.week.ago, :account => less_recent_account)
    
    accounts = Account.by_most_recently_published
    accounts.first.should == recent_account
    accounts.last.should == less_recent_account 
  end
    
  describe "role manager" do
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