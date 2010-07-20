require 'spec_helper'

describe DocumentsHelper do
  include DocumentsHelper
  
  it "should extract Time object from parameter hash" do
    extract_time({  :month =>"1", 
                    :minute=>"31", 
                    :hour=>"11", 
                    :day=>"26", 
                    :year=>"2010"
                }).should == Time.local(2010, 1, 26, 11, 31)
    extract_time(nil).should == nil
  end
  
  describe "publication status" do    
    def current_user
      nil # Publication status checks the current_user
    end

    it "should return an article's publication status" do
      draft_article = Factory(:draft_article)
      publication_status_for(draft_article).should eql("Draft")

      user = Factory(:user)
      draft_article.sign_off(user)
      publication_status_for(draft_article).should eql("Signed off by <strong>#{user.name}</strong>, <strong>#{draft_article.sign_offs.last.created_at.to_s(:date)}</strong> at <strong>#{draft_article.sign_offs.last.created_at.to_s(:time)}</strong>")

      scheduled_article = Factory(:scheduled_article)
      publication_status_for(scheduled_article).should eql("Scheduled")

      published_article = Factory(:published_article)
      publication_status_for(published_article).should be_blank
    end
    
    it "should return an entry's publication status" do
      draft_entry = Factory(:draft_entry)
      publication_status_for(draft_entry).should eql("Draft")

      scheduled_entry = Factory(:scheduled_entry)
      publication_status_for(scheduled_entry).should eql("Scheduled")

      published_entry = Factory(:detailed_entry)
      publication_status_for(published_entry).should be_blank
    end
		
		it "should return an appropriate document link for current user" do
		  article = Factory(:article)
		  current_user = Factory(:user) #just some user
		  document_url_for_user(article, current_user).should == account_article_url(article.account, article)
		  
		  article.owner = current_user
		  document_url_for_user(article, current_user).should == edit_account_article_url(article.account, article)
		  
		  admin_user = Factory(:user)
		  admin_user.has_role "admin"
		  document_url_for_user(article, admin_user).should == edit_account_article_url(article.account, article)
		  
		  account_manager = Factory(:user)
		  account_manager.has_role("manager", article.account)
		  document_url_for_user(article, admin_user).should == edit_account_article_url(article.account, article)
	  end
  end
end