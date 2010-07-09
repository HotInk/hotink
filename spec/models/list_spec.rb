require 'spec_helper'

describe List do
    
  subject { Factory(:list) }
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it "should have list items" do
    should have_many(:list_items).dependent(:destroy)
    list = Factory(:list)
    li3 = Factory(:list_item, :position => 3, :list => list)
    li2 = Factory(:list_item, :position => 2, :list => list)
    li1 = Factory(:list_item, :position => 1, :list => list)
    
    list.list_items.should eql([li1, li2, li3])
  end
  
  it { should have_many(:documents).through(:list_items) }

  it "should ensure name is a string that can be converted to a method name" do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name)
    should allow_value('Basic articles').for(:name)
    should allow_value('Basic entry-article').for(:name)
    
    should_not allow_value('').for(:name)
    should_not allow_value("-hey o").for(:name)    
    should_not allow_value("Chris's articles").for(:name)    
    should_not allow_value("Its_for_real").for(:name)    
    should_not allow_value("no <b>funny</b> stuff").for(:name)    
  end
  
  it "should not allow any slugs that match content drop instance methods" do
    list = Factory(:list)
    ContentDrop.instance_methods.each do |method_name|
      list.slug = method_name
      list.should_not be_valid
    end
  end
  
  it "should generate slug that can function as method name" do
    list = Factory(:list, :name => "Basic articles")
    list.slug.should eql("basic_articles")
    
    list.name = "basic-articles"
    list.save
    list.slug.should eql("basic_articles")
  end
  
  describe "document order" do
    before do
      @list = Factory(:list)
      @document1 = Factory(:document)
      @document2 = Factory(:document)
      @document3 = Factory(:document)
      @document4 = Factory(:document)
    end
      
    it "should maintain document order when passed ids" do    
      @list.document_ids = [@document1.id, @document2.id]
      @list.documents.should eql([@document1, @document2])
    
      @list.document_ids = [@document3.id, @document2.id, @document1.id]
      @list.documents.reload.should eql([@document3, @document2, @document1])
    
      @list.document_ids = [@document4.id, @document1.id]
      @list.documents.reload.should eql([@document4, @document1])
    end
    
    it "should maintain document order when passed documents" do
      @list.documents = [@document1, @document2]
      @list.documents.should eql([@document1, @document2])
    
      @list.documents = [@document3, @document2, @document1]
      @list.documents.reload.should eql([@document3, @document2, @document1])
    
      @list.documents = [@document4, @document1]
      @list.documents.reload.should eql([@document4, @document1])
    end
  end
  
  describe "owner management" do
    before do
      @list = Factory(:list)
      @user = Factory(:user)
      @list.owner = @user      
    end
    
    it "should identify its owner, the user who created it" do
      @list.owner.should == @user
    end
    
    it "should replace its owner, if requested" do
      new_user = Factory(:user)
      @list.owner = new_user
      @list.owner.should == new_user   
    end
  end
  
end

