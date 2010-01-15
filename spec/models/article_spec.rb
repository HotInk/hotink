require 'spec_helper'

describe Article do
  before(:each) do
    @article = Article.create!(Factory.attributes_for(:article))
  end
  
  it { should belong_to(:section) }  
  it { should have_one(:checkout) }
  it { should have_one(:pickup) }
  it { should have_many(:issues).through(:printings) }
  
  it "should return articles by section" do
    section = Factory(:category)
    articles = (1..3).collect { Factory(:detailed_article, :section => section) }
    other_section_article = Factory(:detailed_article, :section => Factory(:category))
    
    articles.each do |article|
      Article.in_section(section).should include(article)
    end
    Article.in_section(section).should_not include(other_section_article)
  end
  
  describe "owner management" do
    before do
      @user = Factory(:user)
      @user.has_role('owner', @article)
    end
    
    it "should identify its owner, the user who created it" do
      @article.owner.should == @user
    end
    
    it "should replace its owner, if requested" do
      new_user = Factory(:user)
      @article.owner = new_user
      @article.owner.should == new_user   
    end
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

  it "should know the appropriate permission string, based on its publication status" do
    draft = Factory(:draft_article)
    recently_published = Factory(:published_article)
    scheduled = Factory(:scheduled_article)

    published_a_while_ago = Factory(:published_article, :published_at => 22.days.ago)
    
    draft.is_editable_by.should == "(owner of article) or (editor of account) or (manager of account) or admin"
    recently_published.is_editable_by.should == "(manager of account) or (editor of account) or admin"
    scheduled.is_editable_by.should == "(manager of account) or (editor of account) or admin"
    
    published_a_while_ago.is_editable_by.should == "(manager of account) or admin"
  end
  
  describe "staff member sign-off" do
    before do
      @draft = Factory(:draft_article)
      @published = Factory(:detailed_article)
      
      @user = Factory(:user)
    end
    
    it { should have_many(:sign_offs) }
    
    it "should allow staff members to sign off on articles" do
      @draft.sign_off(@user)
      @draft.save
      
      @draft.status.should == "Awaiting attention"
      @draft.signed_off_by?(@user).should be_true
    end
    
    it "should identify articles that have been signed off but are not published" do
      @draft.sign_off(@user)
      @draft.save
      Article.awaiting_attention.all.should include(@draft)
      
      @draft.revoke_sign_off(@user)
      @draft.save
      Article.awaiting_attention.all.should_not include(@draft)      

      @draft.publish
      @draft.save
      Article.awaiting_attention.all.should_not include(@draft)
    end
    
    it "should know whether its been signed off on and is awaiting attention from another user" do
      @draft.sign_off(@user)
      @draft.save
      
      @draft.awaiting_attention?.should be_true
      @published.awaiting_attention?.should be_false
    end
    
    it "should only allow sign-off on draft articles" do
      @draft.sign_off(@user)
      @draft.signed_off_by?(@user).should be_true
      
      @published.sign_off(@user)
      @published.signed_off_by?(@user).should be_false
    end

    it "should allow a user to revoke sign-off" do
      @draft.sign_off(@user)
      @draft.save
      @draft.signed_off_by?(@user).should be_true
      
      @new_user = Factory(:user)
      @draft.sign_off(@new_user)
      @draft.revoke_sign_off(@new_user)
      @draft.signed_off_by?(@new_user).should be_false
      Article.awaiting_attention.should include(@draft)
      
      @draft.revoke_sign_off(@user)
      @draft.signed_off_by?(@user).should be_false
      Article.awaiting_attention.should_not include(@draft)
    end
  end
  
end