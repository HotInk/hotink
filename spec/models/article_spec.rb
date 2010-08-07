require 'spec_helper'

describe Article do
  before(:each) do
    @article = Article.create!(Factory.attributes_for(:article))
  end
  
  it { should belong_to(:section) }  
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
  
  it "should create an excerpt in none is set" do
    article = Factory(:article, :summary => "this article is summary")
    article.excerpt.should == "this article is summary"
    
    bodytext = <<-LONGTEXT
    Breaking into Toronto’s very well-established arts scene can present a huge challenge for even the gutsiest BFA graduate. There’s the intimidation that comes from approaching well-known artists and galleries, the fight to get noticed in a competitive field, and rents that rise whenever the New York Times declares your once-affordable neighbourhood “the next big thing.”

    So, what’s a twentysomething artist to do? Band together with others in the same predicament, of course. Three new collective-run artist spaces in Kensington Market prove that they can tough it out with a little help from their friends.

    ###The venue: Double Double Land (209 Augusta Ave.)

    “Did I mention I can bring big propane burners?” Julia makes notes to her sketchbook using a thick marker.

    “Yeah, that would be great,” Dan replies.

    “Good, because I want to cook with them in the back room.”

    Julia Kennedy is planning a barbeque soirée, the first in a series of themed culinary events that Double Double Land is hosting this year. She’s discussing her proposal in the kitchen of the combined performance space/apartment with residents Jon McCurley, Daniel Vila, Rob Gordon, and Steve Thomas. The room’s industrial appliances and vents, relics of a past life, are softened in the presence of tattered cookbooks and Craigslist lamps.

    The loft space atop La Rosa Bakery used to be an office, then an after-hours club. It was Vila who discovered it after being kicked out of Jamie’s Ar")
  LONGTEXT
    article = Factory(:article, :bodytext => bodytext, :summary => nil)
    article.excerpt.should == "Breaking into Toronto’s very well-established arts scene can present a huge challenge for even the gutsiest BFA graduate. There’s the intimidation that comes from approaching well-known artists and galleries, the fight to get noticed in a competitive field, and rents that rise whenever the New York Times declares your once-affordable neighbourhood “the next big thing.” So, what’s a twentysomething artist to do? Band together with others in the same predicament, of course. Three new collective-run artist spaces in Kensington Market prove that they can tough it out with a little help from their friends. ###The venue: Double Double Land (209 Augusta Ave.) “Did I mention I can bring big propane burners?” Julia makes notes to her sketchbook using a thick..."
  end
  
  it "should break up a comma (with 'and') seperated string of authors' names to create authors array" do
    @article.authors_list = "Lilly, Marshall and Robin"
    @article.authors.length.should == 3
  end
  
  it "should generate liquid variables for templates" do
    article = Factory(:detailed_article)
    article.to_liquid.should == {'title' => article.title, 'subtitle' => article.subtitle, 'authors_list' => article.authors_list, 'bodytext' => article.bodytext, 'excerpt' => article.excerpt, 'id' => article.id.to_s }
  end

  describe "permissions" do
    it "should know who has permission to edit/update, based on its publication status" do
      draft = Factory(:draft_article)
      recently_published = Factory(:published_article)
      scheduled = Factory(:scheduled_article)

      published_a_while_ago = Factory(:published_article, :published_at => 22.days.ago)
    
      draft.is_editable_by.should == "(owner of article) or (editor of account) or (manager of account) or admin"
      recently_published.is_editable_by.should == "(manager of account) or (editor of account) or admin"
      scheduled.is_editable_by.should == "(manager of account) or (editor of account) or admin"
    
      published_a_while_ago.is_editable_by.should == "(manager of account) or admin"
    end
  
    it "should know who has permission to publish" do
      article = Factory(:article)
      article.is_publishable_by.should eql("(manager of account) or admin")
    end
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

  it "should make sure the site is always sorted (categorized) into it's primary section" do
    category = Factory(:category, :account => @article.account)
    @article.categories.should_not include(category)
    @article.section = category
    @article.save
    @article.categories.should include(category)
  end
  
  it "should add tags" do
    @article.tag("testing, one, two, three")
    @article.tag_list.to_s.should == "testing, one, two, three"
    @article.tag("four")
    @article.tag_list.to_s.should == "testing, one, two, three, four"
  end

  describe "network" do
    before do
      @article.publish!
    end
    
    it { should have_many(:checkouts).dependent(:destroy) }
    it { should have_one(:checkout).dependent(:destroy) }
    
    it "should know it's network original, if it has one" do
      account = Factory(:account)
      Factory(:membership, :network_owner => account, :account => @article.account)
      network_copy = account.make_network_copy(@article)
      
      network_copy.network_original.should eql(@article)
    end
  end
end