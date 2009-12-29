require 'spec_helper'

describe Blog do
  before(:each) do
    @blog = Blog.create!(Factory.attributes_for(:blog))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should validate_presence_of(:title) }
end
