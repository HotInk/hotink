require 'spec_helper'

describe Article do
  before(:each) do
    @article = Article.create!(Factory.attributes_for(:article))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
end