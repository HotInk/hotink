require 'spec_helper'

describe User do
  before(:each) do
    @user = User.create!(Factory.attributes_for(:user))
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
end