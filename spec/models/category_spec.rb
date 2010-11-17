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

  it "should return main categories, aliased as sections" do
    main_category = Factory(:category)
    subcategory = Factory(:category, :parent => main_category)
    
    Category.main_categories.should include(main_category)
    Category.main_categories.should_not include(subcategory)
    
    Category.sections.should include(main_category)
    Category.sections.should_not include(subcategory) 
  end
  
  it "should find subcategories by path" do
    category1 = Factory(:category)
    category2 = Factory(:category, :parent => category1) 
    category3 = Factory(:category, :parent => category2)
    
    Category.find_by_path("#{category1.slug}").should == category1
    Category.find_by_path(["#{category1.slug}"]).should == category1
    Category.find_by_path("#{category1.slug}/#{category2.slug}").should == category2
    Category.find_by_path([category1.slug, category2.slug]).should == category2
    Category.find_by_path("#{category1.slug}/#{category2.slug}/#{category3.slug}").should == category3
    Category.find_by_path([category1.slug, category2.slug, category3.slug]).should == category3
  end
  
  it "should know it's path" do
    category1 = Factory(:category)
    category2 = Factory(:category, :parent => category1) 
    category3 = Factory(:category, :parent => category2)
    
    category1.path.should == "/#{category1.slug.downcase}"
    category3.path.should == "/#{category1.slug.downcase}/#{category2.slug.downcase}/#{category3.slug.downcase}"
  end
  
  describe "slug" do
    it { should validate_uniqueness_of(:slug).scoped_to(:account_id, :parent_id) } 
    it { should have_db_index(:slug) }
    
    it "should be a uri-friendly string" do
      should_not allow_value("").for(:slug)
      should allow_value("thecategory123").for(:slug)
      should allow_value("the-category-123").for(:slug)
      should_not allow_value("the#category").for(:slug)
      should_not allow_value("the category").for(:slug)
      should_not allow_value("the'category").for(:slug)
      should_not allow_value("TheCategory").for(:slug)      
    end
    
    it "should auto-generate slug if none exists" do
      category = Factory(:category, :name => "Exciting! This Category's exciting")
      category.slug.should eql("exciting-this-categorys-exciting")
    end
  end
  
  describe "#to_json" do
    it "should return json representation of category" do
      category = Factory  :category,
                          :name => "a title"

      category_json = Yajl::Parser.parse category.to_json
      category_json["id"].should == category.id
      category_json["type"].should == "Category"
      category_json["name"].should == category.name
    end
    
    it "should include subcategories" do
      category = Factory(:category)
      subcategories = (1..3).collect { Factory(:category, :parent => category) }
      category_json = Yajl::Parser.parse category.to_json
      category_json["subcategories"].should be_an(Array)
    end
  end
end
