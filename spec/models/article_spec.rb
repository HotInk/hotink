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
    original = Factory(:detailed_article_with_mediafiles)
    new_account = Factory(:account)
    photocopy = original.photocopy(new_account)
    
    photocopy.should_not be_new_record
    photocopy.account.should == new_account
    photocopy.section.should be_nil
    photocopy.status.should be_nil
    
    photocopy.authors_list.should == original.authors_list
    
    photocopy.mediafiles.length.should == original.mediafiles.length
  end
  
  it "should generate liquid variables for templates" do
    article = Factory(:detailed_article)
    article.to_liquid.should == {'title' => article.title, 'subtitle' => article.subtitle, 'authors_list' => article.authors_list, 'bodytext' => article.bodytext, 'id' => article.id.to_s }
  end
  
  it "should know its bodytext word count" do
    article = Factory(:article)
    article.bodytext = "this short article has a grand total of ten words"
    article.word_count.should == 10
    
    article.bodytext = ""
    article.word_count.should == 0
  end
end