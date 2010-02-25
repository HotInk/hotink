require 'spec_helper'

describe Document do
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  
  it { should have_many(:authorships).dependent(:destroy) }
  it { should have_many(:authors).through(:authorships) }

  it { should have_many(:printings).dependent(:destroy) }
  it { should have_many(:issues).through(:printings) }
  
  it { should belong_to(:section) }
  
  it { should have_many(:sortings).dependent(:destroy) }
  it { should have_many(:categories).through(:sortings) }

  it { should have_many(:waxings).dependent(:destroy) }
  it { should have_many(:mediafiles).through(:waxings) }
  it { should have_many(:images).through(:waxings) }

  
  describe "publication status" do
    before(:each) do
      @untouched = Factory(:article)
      @draft = Factory(:article, :created_at => 1.day.ago)
      @published = Factory(:published_article)
      @scheduled = Factory(:published_article, :published_at => Time.now + 1.day)
    end
    
    it "should identify drafts" do
      Document.drafts.should include(@untouched)
      Document.drafts.should include(@draft)
      Document.drafts.should_not include(@published)
      Document.drafts.should_not include(@scheduled)
    end

    it "should identify articles scheduled to publish" do
      Document.scheduled.should_not include(@untouched)
      Document.scheduled.should_not include(@draft)
      Document.scheduled.should_not include(@published)
      Document.scheduled.should include(@scheduled)
    end

    it "should identify articles already published" do
      Document.published.should_not include(@untouched)
      Document.published.should_not include(@draft)
      Document.published.should include(@published)
      Document.published.should_not include(@scheduled)
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
      @untouched.draft?.should be_true
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
    
    Document.published.by_date_published.first.should == first_article
    Document.published.by_date_published.second.should == second_article
  end
  
  describe "publishing a document" do
    it "should publish documents, as requested" do
      article = Factory(:draft_article)
      article.publish
      article.save
      Document.published.all.should include(article)
      Document.drafts.all.should_not include(article)
    end
    
    it "should schedule documents, as requested" do
      article = Factory(:draft_article)
      article.schedule(Time.now + 1.day)
      article.save
      Document.scheduled.all.should include(article)
      Document.drafts.all.should_not include(article)
    end
  end

  it "should know its bodytext word count" do
    article = Factory(:article)
    article.bodytext = "this short article has a grand total of ten words"
    article.word_count.should == 10
    
    article.bodytext = ""
    article.word_count.should == 0
    
    article.bodytext = nil
    article.word_count.should == 0
  end
end
