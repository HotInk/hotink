require 'spec_helper'

describe Article do
  before(:each) do
    @article = Article.create!(Factory.attributes_for(:article))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  
  it { should belong_to(:section) }
  
  it { should have_one(:checkout) }
  it { should have_one(:pickup) }
  
  it { should have_many(:issues).through(:printings) }
  
  describe "publication status" do
    before(:each) do
      @untouched = Factory(:article)
      @draft = Factory(:article, :created_at => 1.day.ago)
      @published = Factory(:published_article)
      @scheduled = Factory(:published_article, :published_at => Time.now + 1.day)
    end
    
    it "should identify drafts" do
      Article.drafts.should_not include(@untouched)
      Article.drafts.should include(@draft)
      Article.drafts.should_not include(@published)
      Article.drafts.should_not include(@scheduled)
    end

    it "should identify articles scheduled to publish" do   
      Article.scheduled.should_not include(@untouched)
      Article.scheduled.should_not include(@draft)
      Article.scheduled.should_not include(@published)
      Article.scheduled.should include(@scheduled)
    end

    it "should identify articles already published" do
      Article.published.should_not include(@untouched)
      Article.published.should_not include(@draft)
      Article.published.should include(@published)
      Article.published.should_not include(@scheduled)
    end
        
    it "should know it's publication status" do
      @untouched.published?.should be_false
      @draft.published?.should be_false
      @published.published?.should be_true
      @scheduled.published?.should be_false
    end
    
    it "should know it's scheduled status" do
      @untouched.scheduled?.should be_false
      @draft.scheduled?.should be_false
      @published.scheduled?.should be_false
      @scheduled.scheduled?.should be_true
    end
    
    it "should know it's draft status" do
      @untouched.draft?.should be_false
      @draft.draft?.should be_true
      @published.draft?.should be_false
      @scheduled.draft?.should be_false
    end
    
    it "should know it's untouched status" do
      @untouched.untouched?.should be_true
      @draft.untouched?.should be_false
      @published.untouched?.should be_false
      @scheduled.untouched?.should be_false
    end
  end
  
  it "should return articles by date published" do
    first_article = Factory(:detailed_article, :published_at => 1.day.ago)
    second_article = Factory(:detailed_article, :published_at => 3.days.ago)
    
    Article.published.by_date_published.first.should == first_article
    Article.published.by_date_published.second.should == second_article
  end
  
  it "should return articles by section" do
    section = Factory(:category)
    articles = (1..3).collect { Factory(:detailed_article, :section => section) }
    other_section_article = Factory(:detailed_article, :section => Factory(:category))
    
    articles.each do |article|
      Article.in_section(section).should include(article)
    end
    Article.in_section(section).should_not include(other_section_article)
  end
  
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