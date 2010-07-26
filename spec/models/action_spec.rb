require 'spec_helper'

describe Action do
  
  describe "Publish action" do
    before do
      @article = Factory(:article)
      PublishAction.new(@article).execute
    end
    
    it "should publish document" do
      @article.should be_published
    end
  end
  
  describe "Schedule action" do
    before do
      @article = Factory(:article)
      ScheduleAction.new(@article, :schedule => { :year => "2015", :month => "3", :day => "4", :hour => "12", :minute => "35" }).execute
    end
    
    it "should schedule document" do
      @article.should be_scheduled
    end
  end
  
  describe "Delete action" do
    before do
      @article = Factory(:article)
      DeleteAction.new(@article).execute
    end
    
    it "should delete record" do
      lambda { Document.find(@article) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "Unpublish action" do
    before do
      @article = Factory(:published_article)
      UnpublishAction.new(@article).execute
    end
    
    it "should unpublish document" do
      @article.should be_draft
    end
  end
  
  describe "Set section action" do
    before do
      @article = Factory(:article)
      @category = Factory(:category, :account => @article.account)
      SetSectionAction.new(@article, :category_id => @category.id).execute
    end
    
    it "should make category into document's section" do
      @article.section.should == @category
    end
  end
  
  describe "Add category action" do
    before do
      @article = Factory(:article)
      @category = Factory(:category, :account => @article.account)
      AddCategoryAction.new(@article, :category_id => @category.id).execute
    end
    
    it "should add category to document" do
      @article.categories.should include(@category)
    end
  end
  
  describe "Attach to issue action" do
    before do
      @article = Factory(:article)
      @issue = Factory(:issue, :account => @article.account)
      AddIssueAction.new(@article, :issue_id => @issue.id).execute
    end
    
    it "should add tag" do
      @article.issues.should include(@issue)
    end
  end
  
end
