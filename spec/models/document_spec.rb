require 'spec_helper'

describe Document do
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  
  describe "authors" do
    it { should have_many(:authorships).dependent(:destroy) }
    it { should have_many(:authors).through(:authorships) }
    
    it "should generate appropriate authors JSON" do
      lilly = Factory(:author, :name => "Lilly Aldrin")
      barney = Factory(:author, :name => "Barney Stinson")
      document = Factory(:document, :authors => [lilly, barney])

      document.authors_json.should eql([{ "id" => lilly.id, "name" => lilly.name },{ "id" => barney.id, "name" => barney.name }].to_json)
    end
    
    it "should create a human readable list of authors' names" do
      document = Factory(:document)
      document.authors = [Factory(:author, :name => "Lilly")]
      document.authors_list.should == "Lilly"
  
      document.authors << Factory(:author, :name => "Marshall")
      document.authors_list.should == "Lilly and Marshall"
  
      document.authors << Factory(:author, :name => "Robin")
      document.authors_list.should == "Lilly, Marshall and Robin"
  
      document.authors << Factory(:author, :name => "Barney")
      document.authors_list.should == "Lilly, Marshall, Robin and Barney"
    end
    
    it "should add authors from a mixed list of IDs and new author names" do
      document = Factory(:document, :authors => [Factory(:author, :name => "Soon to be removed")])
      
      lilly = Factory(:author, :name => "Lilly Aldrin", :account => document.account)
      barney = Factory(:author, :name => "Barney Stinson", :account => document.account)
      
      document.author_ids = "#{lilly.id}, Marshall Ericson,#{barney.id}"
      marshall = document.account.authors.find_by_name("Marshall Ericson")
      document.authors.should == [lilly, marshall, barney]
    end
  end

  it { should have_many(:printings).dependent(:destroy) }
  it { should have_many(:issues).through(:printings) }
  
  it { should belong_to(:section) }
  
  it { should have_many(:sortings).dependent(:destroy) }
  it { should have_many(:categories).through(:sortings) }

  describe "attached media" do
    it { should have_many(:waxings).dependent(:destroy) }
    it { should have_many(:mediafiles).through(:waxings) }
    it { should have_many(:images).through(:waxings) }
    it { should have_many(:audiofiles).through(:waxings) }
  
    it "should find the waxing that attaches a mediafile" do
      document = Factory(:document)
      mediafile = Factory(:mediafile, :account => document.account)
      waxing = Waxing.create(:document => document, :mediafile => mediafile, :account => document.account)
      
      document.waxing_for(mediafile).should == waxing
      
      another_mediafile = Factory(:mediafile, :account => document.account)
      document.waxing_for(another_mediafile).should be_nil
    end
    
    it "should find the caption for an attached mediafile" do
      document = Factory(:document)
      mediafile = Factory(:mediafile, :account => document.account)
      waxing = Waxing.create(:caption => "Some test you got here", :document => document, :mediafile => mediafile, :account => document.account)
      
      document.caption_for(mediafile).should == "Some test you got here"
      
      another_mediafile = Factory(:mediafile, :account => document.account)
      document.caption_for(another_mediafile).should be_nil
    end
  end
  
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

    it "should identify articles that are either published or scheduled" do
      Document.published_or_scheduled.should_not include(@untouched)
      Document.published_or_scheduled.should_not include(@draft)
      Document.published_or_scheduled.should include(@published)
      Document.published_or_scheduled.should include(@scheduled)
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
  
  describe "attributes" do
    it "should return a default headline if none is set" do
      article = Factory(:article)
      article.title = ""
      article.title.should == "(no headline)"
    
      article.title = "A real title"
      article.title.should == "A real title"
    end
  
    it "should return an appropriate date, depending on its publication status" do
      article = Factory(:article)
      article.date.should == article.updated_at
      article.publish!(Time.now - 1.day)
      article.date.should == article.published_at
      article.publish!(Time.now + 1.day)
      article.date.should == article.published_at
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
  
  describe "publishing a document" do
    it "should publish documents, as requested" do
      article = Factory(:draft_article)
      article.publish
      article.save
      Document.published.all.should include(article)
      Document.drafts.all.should_not include(article)
    
      article = Factory(:draft_article)
      article.publish(nil)
      article.save
      Document.published.all.should include(article)
      Document.drafts.all.should_not include(article)
    end
    
    it "should schedule documents, as requested" do
      #Old, deprecated way
      article1 = Factory(:draft_article)
      article1.schedule(Time.now + 1.day)
      article1.save
      Document.scheduled.all.should include(article1)
      Document.drafts.all.should_not include(article1)
    
      #Better way
      article2 = Factory(:draft_article)
      article2.publish(Time.now + 1.day)
      article2.save
      Document.scheduled.all.should include(article2)
      Document.drafts.all.should_not include(article2)
    end
  end

  it "should have a default per-page value for pagination" do
    Document.per_page.should == 10
  end
  
  describe "owner management" do
    before do
      @article = Factory(:article)
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

  describe "comments" do
    it { should have_many(:comments).dependent(:destroy) } 
    
    describe "comment status" do
      describe "load default from setting" do
        it "should enable comments if no default is specified" do
          document = Factory(:document)
          document.comment_status.should eql('enabled')
        end

        it "should use default, if specified"
      end

      it "should lock comments" do
       document = Factory(:document)
       document.lock_comments
       document.comment_status.should eql('locked')
     end

      it "should disable comments" do
        document = Factory(:document)
        document.disable_comments
        document.comment_status.should eql('disabled')
      end

      it "should enable comments" do
        document = Factory(:document)
        document.lock_comments
        document.enable_comments
        document.comment_status.should eql('enabled')
      end
    end
  end

  describe "#to_json" do
    it "should return json representation of document" do
      document = Factory  :document,
                          :title => "a title",
                          :subtitle => "a subtitle",
                          :authors => (1..2).collect { Factory(:author) },
                          :summary => "a summary",
                          :bodytext => "some bodytext"
                          #:tag_list => "one tag, two tag"
      document_json = Yajl::Parser.parse document.to_json
      
      document_json["id"].should == document.id
      document_json["title"].should == document.title
      document_json["subtitle"].should == document.subtitle
      document_json["authors_list"].should == document.authors_list
      document_json["summary"].should == document.summary
      document_json["bodytext"].should == RDiscount.new(document.bodytext).to_html
      document_json["updated_at"].should == document.updated_at.to_datetime.strftime("%b. %e, %Y %l:%m%P") 
    end
    
    it "should include mediafiles" do
      mediafiles = (1..2).collect { Factory(:mediafile) }
      mediafiles += (1..2).collect { Factory(:image) }
      mediafiles += (1..2).collect { Factory(:audiofile) }
      
      document = Factory  :document,
                          :mediafiles => mediafiles
      document_json = Yajl::Parser.parse document.to_json
      
      mediafiles_array = mediafiles.collect do |mediafile|
        Waxing.create :caption => "Some test you got here", 
                      :document => document, 
                      :mediafile => mediafile,
                      :account => document.account
                      
        mediafile_hash = {  "title" => mediafile.title,
                            "caption" => document.caption_for(mediafile),
                            "type" => mediafile.class.name,
                            "authors_list" => mediafile.authors_list,
                            "url" => mediafile.file.url,
                            "content_type" => mediafile.file_content_type }
                            
        if mediafile.kind_of? Image
          mediafile_hash.merge!({ 
            "url" => {  "original" => mediafile.file.url(:original),
                        "thumb" => mediafile.file.url(:thumb),
                        "small" => mediafile.file.url(:small),
                        "medium" => mediafile.file.url(:medium),
                        "large" => mediafile.file.url(:large),
                        "system_default" => mediafile.file.url(:system_default),
                        "system_thumb" => mediafile.file.url(:system_thumb),
                        "system_icon" => mediafile.file.url(:system_icon) }
          })
        end
        mediafile_hash
      end
      
      document_json["mediafiles"].should == mediafiles_array
    end
  end
end
