require 'spec_helper'

describe Category do
  before(:each) do
    @category = Category.create!(Factory.attributes_for(:category))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  it { should validate_presence_of(:name) }
  
  it { should have_many(:subcategories) }
  
  it "should return active and inactive categories" do
    active_category = Factory(:category)
    inactive_category = Factory(:inactive_category)
    
    Category.active.all.should include(active_category)
    Category.active.all.should_not include(inactive_category)
    
    Category.inactive.all.should include(inactive_category)
    Category.inactive.all.should_not include(active_category)
  end

  it "should return sections" do
    main_category = Factory(:category)
    subcategory = Factory(:category, :parent => main_category)
    
    Category.sections.should include(main_category)
    Category.sections.should_not include(subcategory) 
  end
end
