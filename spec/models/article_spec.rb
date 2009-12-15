require 'spec_helper'

describe Article do
  before(:each) do
    @article = Article.create!(Factory.attributes_for(:article))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  
  it { should have_one(:checkout) }
  it { should have_one(:pickup) }
  
  it "should create a human readable list of authors' names" do
    @article.authors = [Factory(:author, :name => "Lilly")]
    @article.authors_list.should == "Lilly"
    
    @article.authors << Factory(:author, :name => "Marshall")
    @article.authors_list.should == "Lilly and Marshall"
    
    @article.authors << Factory(:author, :name => "Robin")
    @article.authors_list.should == "Lilly, Marshall and Robin"
    
    @article.authors << Factory(:author, :name => "Barney")
    @article.authors_list.should == "Lilly, Marshall, Robin and Barney"
  end
  
  it "should break up a comma (with 'and') seperated string of authors' names to create authors array" do
    @article.authors_list = "Lilly, Marshall and Robin"
    @article.authors.length.should == 3
  end
  
  it "should create photocopies of itself for wire distribution" do
    original = Factory(:detailed_article)
    photocopy = original.photocopy
    photocopy.account.should be_nil
    photocopy.section.should be_nil
    photocopy.status.should be_nil
    photocopy.authors_list.should == original.authors_list
  end
end