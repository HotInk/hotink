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
  
  it "should find accounts in order of most recently published articles" #do
    #recent_account = Factory(:account)
    #less_recent_account = Factory(:account)
    #recent_article = Factory(:published_article, :title => "Most recent", :account => recent_account)
    #less_recent_article = Factory(:published_article, :title => "Less recent", :published_at => 1.day.ago, :account => less_recent_account)
    
    #accounts = Account.by_most_recent_article
    #accounts.first.should == recent_account
    #accounts.last.should == less_recent_account 
  #end
    
end