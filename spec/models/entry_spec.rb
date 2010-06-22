require 'spec_helper'

describe Entry do
  before do
    @account = Factory(:account)
  end
  
  it { should belong_to(:blog) }
  #it "should belong to blog" do
    #blog = Factory(:blog, :account => @account)
   # entry = Factory(:entry, :blog => blog, :account => @account)
    #entry.blog.should eql(blog)
  #end
  
  describe "permissions" do  
    it "should know who has permission to make changes, based on its publication status" do
      draft = Factory(:entry, :account => @account)
      recently_published = Factory(:detailed_entry, :account => @account)
      scheduled = Factory(:scheduled_entry, :account => @account)

      published_a_while_ago = Factory(:detailed_entry, :published_at => 22.days.ago, :account => @account)
    
      draft.is_editable_by.should == "(owner of entry) or (editor of blog) or (manager of account) or admin"
      recently_published.is_editable_by.should == "(owner of entry) or (editor of blog) or (manager of account) or admin"
      scheduled.is_editable_by.should == "(owner of entry) or (editor of blog) or (manager of account) or admin"
    
      published_a_while_ago.is_editable_by.should == "(editor of blog) or (manager of account) or admin"
    end
  
    it "should know which user roles are empowered to publish, schedule or unpublish" do
      entry = Factory(:entry)
      entry.is_publishable_by.should eql("(owner of entry) or (manager of account) or (editor of blog) or admin")
    end
  end
end
