require 'spec_helper'

describe Category do
  before(:each) do
    @category = Category.create!(Factory.attributes_for(:category))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  it { should validate_presence_of(:name) }
end
