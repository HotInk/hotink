require 'spec_helper'

describe Checkout do
  before(:each) do
    @checkout = Factory(:checkout)
  end
  it { should belong_to(:user) }

  it { should belong_to(:original_article) }
  it { should validate_presence_of(:original_article) }
  
  it { should belong_to(:duplicate_article) }
  it { should validate_presence_of(:duplicate_article) }  
end
