require 'spec_helper'

describe User do
  before(:each) do
    @user = Factory(:user)
  end
    
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  
end