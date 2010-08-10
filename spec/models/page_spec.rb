require 'spec_helper'

describe Page do
  
  subject { Factory(:page) }
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should belong_to(:template) }
  it { should belong_to(:parent) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:account_id, :parent_id) }
  it "should ensure name is URI-safe" do
    should allow_value("testpage").for(:name)
    should allow_value("test-page").for(:name)  
    should allow_value("test_page").for(:name)
    should allow_value("testpage1").for(:name)
    
    should_not allow_value('test/page').for(:name)
    should_not allow_value("test page").for(:name)
    should_not allow_value("test$page").for(:name)
  end
  
  describe "nesting" do
    before(:each) do
      @parent1 = Factory(:page) 
      @parent2 = Factory(:page) 
      @child1 = Factory(:page, :parent => @parent1)
      @child2 = Factory(:page, :parent => @parent2)
      @grandchild1 = Factory(:page, :parent => @child1)
    end
    
    it "should identify top-level pages" do   
      Page.main_pages.should include(@parent1)
      Page.main_pages.should include(@parent2)
      Page.main_pages.should_not include(@child1)
      Page.main_pages.should_not include(@child2)
      Page.main_pages.should_not include(@grandchild1)
    end
    
    it "should know what it's child pages are" do
      @parent1.child_pages.should include(@child1)
      @parent2.child_pages.should include(@child2)
      @child1.child_pages.should include(@grandchild1)

      @parent1.child_pages.should_not include(@parent2)
      @parent1.child_pages.should_not include(@grandchild1)
    end
  end
  
  it "should know it's url" do
    page1 = Factory(:page)
    page2 = Factory(:page, :parent => page1) 
    page3 = Factory(:page, :parent => page2)
    
    page1.url.should == "/#{page1.name.downcase}"
    page3.url.should == "/#{page1.name.downcase}/#{page2.name.downcase}/#{page3.name.downcase}"
  end
  
  it "should find child pages by path" do
    page1 = Factory(:page)
    page2 = Factory(:page, :parent => page1) 
    page3 = Factory(:page, :parent => page2)
    
    Page.find_by_path("#{page1.name}").should == page1
    Page.find_by_path(["#{page1.name}"]).should == page1
    Page.find_by_path("#{page1.name}/#{page2.name}").should == page2
    Page.find_by_path([page1.name, page2.name]).should == page2
    Page.find_by_path("#{page1.name}/#{page2.name}/#{page3.name}").should == page3
    Page.find_by_path([page1.name, page2.name, page3.name]).should == page3
  end
  
  describe "rendering a page as HTML" do
    before do
      @page = Factory(:page, :contents => 'we **got** em')
    end
    
    context "when the page has no template" do
      it "should render its contents as html directly" do
        @page.to_html.should == RDiscount.new(@page.contents).to_html
      end
    end
  
    context "when the page has a template" do
      it "should render its content inside the appropriate template" do
        @page.template = Factory(:page_template, :code => '{{ contents }}' )
        @page.to_html.should == Liquid::Template.parse(@page.template.code).render({'contents' => RDiscount.new(@page.contents).to_html})
      end
    end
  end
end
