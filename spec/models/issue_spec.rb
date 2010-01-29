require 'spec_helper'

describe Issue do
  before(:each) do
    @issue = Issue.create!(Factory.attributes_for(:issue))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should have_many(:articles).through(:printings) }
  
  it { should have_db_column(:processing).of_type(:boolean).with_options(:default => false) }
  it "should identify processed articles" do
    issue = Factory(:issue)
    processing_issue = Factory(:issue_being_processed)
    Issue.processed.should_not include(processing_issue)
    Issue.processed.should include(issue)
  end
end
