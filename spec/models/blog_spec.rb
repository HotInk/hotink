require 'spec_helper'

describe Blog do
  before(:each) do
    @blog = Blog.create!(Factory.attributes_for(:blog))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should validate_presence_of(:title) }
  it { should validate_uniqueness_of(:title).scoped_to(:account_id) }
  
  describe "slug" do
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug).scoped_to(:account_id) } 
    it { should have_db_index(:slug) }
  end
end
