require 'spec_helper'

describe HotinkApi do
  include Rack::Test::Methods

  def app
    HotinkApi
  end

  before do
    @account = Factory(:account)
    stubbed_uri = Addressable::URI.parse("http://#{@account.name}.yoursite.net")
    Addressable::URI.stub(:parse).and_return(stubbed_uri)
  end
  
  after do
    Account.delete_all
  end
  
  describe "Articles" do
    describe "GET to /articles/:id" do
      context "requesting a published article" do
        before do
          @article = Factory(:detailed_article, :account => @account)
        end
        
        it "should return an XML representation" do
          get "/articles/#{@article.to_param}.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @article.to_xml
        end
        
        it "should return a JSON representation" do
          get "/articles/#{@article.to_param}.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @article.to_json
        end
      end
      
      context "requesting an draft article" do
        before do
          @draft_article = Factory(:draft_article, :account => @account)
        end
        
        it "should respond with not found" do
          get "/articles/#{@draft_article.to_param}.xml"
          last_response.should be_not_found
          
          get "/articles/#{@draft_article.to_param}.json"
          last_response.should be_not_found
        end
      end
      
      context "requesting an scheduled article" do
        before do
          @scheduled_article = Factory(:scheduled_article, :account => @account)
        end
        
        it "should respond with not found" do
          get "/articles/#{@scheduled_article.to_param}.xml"
          last_response.should be_not_found
          
          get "/articles/#{@scheduled_article.to_param}.json"
          last_response.should be_not_found
        end
      end
    end
    
    describe "GET to /articles" do
      before do
        @recently_published_articles = (1..2).collect do |n|
          Factory(:detailed_article, :published_at => n.hours.ago, :account => @account)
        end
        @just_published_article = Factory(:detailed_article, :account => @account)
        draft = Factory(:draft_article, :account => @account)
        scheduled = Factory(:scheduled_article, :account => @account)
      end
      
      it "should return an XML array of only published articles" do
        get "/articles.xml"
        pagination_options = { :page => 1, :per_page => 20 }
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @account.articles.published.
                                              by_date_published(:desc).
                                              paginate(pagination_options).
                                              to_xml
      end

      it "should return an JSON array of only published articles" do
        get "/articles.json"
        pagination_options = { :page => 1, :per_page => 20 }

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @account.articles.published.
                                              by_date_published(:desc).
                                              paginate(pagination_options).
                                              to_json
      end
      
      describe "pagination" do
        before do
          @page = 2
          @per_page = 5
          @paginated_articles = (1..10).collect{ Factory(:detailed_article, :account => @account) }
        end
        
        it "should return paginated xml" do
          get "/articles.xml?page=#{@page}&per_page=#{@per_page}"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @account.articles.published.by_date_published(:desc).paginate(:page => @page, :per_page => @per_page).to_xml
        end
        
        it "should return paginated json" do
          get "/articles.json?page=#{@page}&per_page=#{@per_page}"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @account.articles.published.by_date_published(:desc).paginate(:page => @page, :per_page => @per_page).to_json
        end
      end
      
      describe "requesting a list of articles by id" do
        before do
          @first_article = @recently_published_articles.first
          @second_article = @recently_published_articles.second
        end
        
        it "should return specific articles in xml format" do
          get "/articles.xml", :ids => [@first_article.id, @second_article.id]

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @account.articles.published.all(:conditions => { :id => [@first_article.id, @second_article.id] }).to_xml
        end
        
        it "should return specific articles in json format" do      
          get "/articles.json", :ids => [@first_article.id, @second_article.id]

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @account.articles.published.all(:conditions => { :id => [@first_article.id, @second_article.id] }).to_json
        end
      end

      describe "requesting a list of articles by section" do
        before do
          @category = Factory(:category, :account => @account)
          @articles = (1..3).collect{ Factory(:detailed_article, :section => @category, :account => @account) }     
        end
        
        it "should find articles by section id in xml format" do
          get "/articles.xml", :section_id => @category.id

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @account.articles.published.by_published_at(:desc).paginate(:page => 1, :per_page => 20, :conditions => { :section_id => @category.id }).to_xml
        end
        
        it "should find articles by section id json format" do
          get "/articles.json", :section_id => @category.id

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @account.articles.published.by_published_at(:desc).paginate(:page => 1, :per_page => 20, :conditions => { :section_id => @category.id }).to_json
        end
      end
      
      describe "requesting a list of articles by tag" do
        before do
          2.times { Factory(:published_article, :account => @account, :tag_list => "flagged") }
        end
        
        it "should find articles by tag in xml format" do
          get "/articles.xml", :tagged_with => "flagged"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @account.articles.tagged_with('flagged', :on => :tags).published.by_published_at(:desc).paginate(:page => 1, :per_page => 20).to_xml        
        end
        
        it "should find articles by tag in json format" do
          get "/articles.json", :tagged_with => "flagged"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @account.articles.tagged_with('flagged', :on => :tags).published.by_published_at(:desc).paginate(:page => 1, :per_page => 20).to_json        
        end
      end
    end
  end
  
  describe "Categories" do
    describe "GET to /categories" do
      before do
        @categories = (1..5).collect { Factory(:category, :account => @account) }
        @inactive_category = Factory(:category, :account => @account, :active => false)
        @subcategories = Factory(:category, :account => @account, :parent => @categories.first)
      end

      it "should return a list of active categories in xml format" do
        get "/categories.xml"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @categories.to_xml
      end
      
      it "should return a list of active categories in json format" do
        get "/categories.json"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        response_array = Yajl::Parser.parse(last_response.body)
        response_array.should be_an(Array) 
        response_array.first["type"].should == "Category"
      end
    end

    describe "GET to /categories/:id.xml" do
      describe "requesting a category by id" do
        before do
          @category = Factory(:category, :account => @account)
        end
        
        it "should find category in xml format" do
          get "/categories/#{@category.id}.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @category.to_xml
        end
        
        it "should find category in json format" do
          get "/categories/#{@category.id}.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @category.to_json
        end
        
        it "should find category by slug" do
          get "/categories/#{@category.slug}.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @category.to_json
        end
      end
      
      describe "requesting category by name" do
        before do
          @category = Factory(:category, :name => "News", :account => @account)
        end
        
        it "should find category in xml format" do
          get "/categories/#{@category.name}.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @category.to_xml
        end
        
        it "should find category in json format" do
          get "/categories/#{@category.name}.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @category.to_json
        end
      end
      
      
    end
  
    describe "GET to /categories/:id/articles.xml" do
      describe "requesting a category's articles by category id" do
        before do
          @category = Factory(:category, :account => @account)
          @articles = (1..3).collect do |n|
            Factory :published_article,
                    :published_at => n.hours.ago,
                    :section => @category,
                    :account => @account
          end
        end
        
        it "should find category's articles in xml format" do
          get "/categories/#{@category.id}/articles.xml"
          
          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @category.articles.published.
                                                 by_date_published(:desc).
                                                 paginate(:page => 1, :per_page => 20).
                                                 to_xml
        end
        
        it "should find category's articles in json format" do
          get "/categories/#{@category.id}/articles.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @category.articles.published.
                                                 by_date_published(:desc).
                                                 paginate(:page => 1, :per_page => 20).
                                                 to_json
        end
        
        it "should find category's articles by slug" do
          get "/categories/#{@category.slug}/articles.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @category.articles.published.
                                                 by_date_published(:desc).
                                                 paginate(:page => 1, :per_page => 20).
                                                 to_json
        end
      end
    end
  end

  describe "issues" do
    describe "GET to issues" do
      before do
        @issues = (1..5).collect { |n| Factory(:issue, :date => n.days.ago,:account => @account) }
        @processing_issue = Factory(:issue_being_processed, :account => @account)
      end

      it "should return an array of published issues in xml format" do
        get "/issues.xml"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"

        @account.issues.processed.should_not include(@processing_issue)
        last_response.body.should == @account.issues.processed.paginate(:page => 1, :per_page => 15, :order => "date DESC").to_xml
      end
      
      it "should return an array of published issues in json format" do
        get "/issues.json"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"

        last_response.body.should == @account.issues.processed.paginate(:page => 1, :per_page => 15, :order => "date DESC").to_json
      end
    end

    describe "GET to /issues/id.xml" do
      it "should return an XML respresentation of the issue" do
        @issue = Factory(:issue, :account => @account)
        get "/issues/#{@issue.id}.xml"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @issue.to_xml
      end
      
      it "should return a JSON respresentation of the issue" do
        @issue = Factory(:issue, :account => @account)
        get "/issues/#{@issue.id}.json"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @issue.to_json
      end

      it "should not return a processing issue" do
        @processing_issue = Factory(:issue_being_processed, :account => @account)
        get "/issues/#{@processing_issue.id}.xml"

        last_response.should be_not_found
      end
    end

    describe "articles" do
      describe "GET to /issues/id/articles" do
        before do
          @issue = Factory(:issue, :account => @account)
          @published_articles = (1..3).collect{ Factory(:detailed_article, :account => @account, :issues => [@issue]) }
        end

        it "should return all of this issues published articles in xml format" do
          get "/issues/#{@issue.id}/articles.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @issue.articles.published.by_published_at(:desc).to_xml
        end

        it "should return all of this issues published articles in json format" do
          get "/issues/#{@issue.id}/articles.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @issue.articles.published.by_published_at(:desc).to_json
        end
        
        it "should not return unpublished articles" do
          @unpublished_article = Factory(:draft_article, :account => @account, :issues => [@issue]) 
          get "/issues/#{@issue.id}/articles.xml"

          last_response.body.should == @issue.articles.published.by_published_at(:desc).to_xml
        end

        it "should return only articles from a certain section, if requested" do
          category = Factory(:category, :account => @account)
          category_articles = (1..4).collect{ Factory(:detailed_article, :account => @account, :issues => [@issue], :section => category) }      
          get "/issues/#{@issue.id}/articles.xml", :section_id => category.id

          last_response.body.should == @issue.articles.in_section(category).by_date_published.to_xml  
        end
      end
    end
  end

  describe "blogs" do
    describe "GET to /blogs.xml" do
      before do
        @blogs = (1..4).collect{ Factory(:blog, :account => @account, :status => true) }
        @inactive_blogs = (1..4).collect{ Factory(:blog, :account => @account, :status => false) }
      end
      
      it "should return an array of blogs in xml format" do     
        get "/blogs.xml"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @account.blogs.active.to_xml
      end
      
      it "should return an array of blogs in JSON format" do    
        get "/blogs.json"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @account.blogs.active.to_json
      end
    end

    describe "GET to /blogs/:id" do
      before do
        @blog = Factory(:blog, :account => @account)
      end
      
      it "should return an xml representation of the blog" do
        get "/blogs/#{@blog.id}.xml"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @blog.to_xml
      end
      
      it "should return a json representation of the blog" do
        get "/blogs/#{@blog.id}.json"

        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @blog.to_json
      end
    end
    
    describe "entries" do
      describe "GET to /entries" do
        before do
          @blog_one = Factory(:blog, :account => @account)
          @blog_two = Factory(:blog, :account => @account)
          @blog_one_entries = (1..3).collect{ |n| Factory(:detailed_entry, :account => @account, :blog => @blog_one) }
          @blog_two_entries = (1..3).collect{ |n|  Factory(:detailed_entry, :account => @account, :blog => @blog_two) }
        end

        describe "requesting most recent entries from all blogs" do
          it "should return entries in xml format" do
            get "/entries.xml"

            last_response.should be_ok
            last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
            last_response.body.should == @account.entries.paginate(:page => 1, :per_page => 20, :order => "published_at DESC", :conditions => { :status => "published" }).to_xml
          end
          
          it "should return entries in json format" do
            get "/entries.json"

            last_response.should be_ok
            last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
            last_response.body.should == @account.entries.paginate(:page => 1, :per_page => 20, :order => "published_at DESC", :conditions => { :status => "published" }).to_json
          end
        end

        describe "requesting entries from one blog" do
          it "should return entries by blog in xml format" do
            get "/entries.xml", :blog_id => @blog_one.id

            last_response.should be_ok
            last_response.headers['Content-Type'].should == "text/xml;charset=utf-8" 
            last_response.body.should == @blog_one.entries.paginate(:page => 1, :per_page => 20, :order => "published_at DESC", :conditions => { :status => "published" }).to_xml       
          end

          it "should return entries by blog in json format" do
            get "/entries.json", :blog_id => @blog_one.id

            last_response.should be_ok
            last_response.headers['Content-Type'].should == "application/json;charset=utf-8" 
            last_response.body.should == @blog_one.entries.paginate(:page => 1, :per_page => 20, :order => "published_at DESC", :conditions => { :status => "published" }).to_json
          end
        end
      end

      describe "GET to /entries/:id" do
        before do
          @entry = Factory(:detailed_entry, :account => @account)
        end
        
        it "should return an XML representation of the entry" do
          get "/entries/#{@entry.id}.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == @entry.to_xml
        end
        
        it "should return a JSON representation of the entry" do
          get "/entries/#{@entry.id}.json"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == @entry.to_json
        end
      end
    end
  end

  describe "query" do
    describe "GET to /query" do
      describe "requesting latest articles by section" do
        before do
          @section_one = Factory(:category, :account => @account)
          @section_two = Factory(:category, :account => @account)
          @section_one_articles = (1..5).collect{ Factory(:article, :account => @account, :section => @section_one) }
          @section_two_articles = (1..5).collect{ Factory(:article, :account => @account, :section => @section_two) }
          @section_two_scheduled = Factory(:scheduled_article, :account => @account, :section => @section_two)
        end
        
        it "should return latest articles in xml format" do
          get "/query.xml", :group_by => "section"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == (@account.articles.in_section(@section_one).published.by_date_published.limited(5) + @account.articles.in_section(@section_two).published.by_date_published.limited(5)).to_xml
        end
        
        it "should return latest articles in json format" do
          get "/query.json", :group_by => "section"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          last_response.body.should == (@account.articles.in_section(@section_one).published.by_date_published.limited(5) + @account.articles.in_section(@section_two).published.by_date_published.limited(5)).to_json
        end
      end
      
      describe "requesting latest entries by blog" do
        before do
          @blog_one = Factory(:blog, :account => @account)
          @blog_two = Factory(:blog, :account => @account)
          @blog_one_entries = (1..5).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog_one) }
          @blog_two_entries = (1..5).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog_two) }
          @blog_one_scheduled = Factory(:scheduled_entry, :account => @account, :blog => @blog_one)
        end
        
        it "should return latest entries in xml format" do
          get "/query.xml", :group_by => "blog"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"

          options = { :conditions => { :status => 'published' }, :limit => 5, :order => "published_at DESC" }
          last_response.body.should == (@blog_one.entries.published.all(options) + @blog_two.entries.published.all(options)).to_xml  
        end
        
        it "should return latest entries in json format" do
          get "/query.json", :group_by => "blog"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"

          options = { :conditions => { :status => 'published' }, :limit => 5, :order => "published_at DESC" }
          last_response.body.should == (@blog_one.entries.published.all(options) + @blog_two.entries.published.all(options)).to_json  
        end
      end
    end
  end

  describe "lead articles" do
    context "with lead articles" do
      before do
        @lead_articles = (1..5).collect{ |n| Factory(:published_article, :title => "Title ##{n}", :account => @account) }
        @account.update_attribute :lead_article_ids, @lead_articles.collect{ |article| article.id  }
      end
      
      it "should return lead articles in xml format" do
        get "/lead_articles.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @lead_articles.to_xml
      end
      
      it "should return an json array" do
        get "/lead_articles.json"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @lead_articles.to_json
      end
    end
    
    context "without lead articles" do
      it "should return an empty xml array" do
        get "/lead_articles.xml"
                
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == Builder::XmlMarkup.new.articles
      end
      
      it "should return an empty json array" do
        get "/lead_articles.json"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == Yajl::Encoder.encode([])
      end
    end
  end
  
  describe "lists" do
    context "requesting list that exists" do
      before do
        @list = Factory :list, :name => "First list", :account => @account
        @list.documents = (1..3).collect { Factory(:published_article, :account => @account) }
      end
      
      it "should return xml list" do
        get "/first_list.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
        last_response.body.should == @list.to_xml
      end
      
      it "should return json list" do
        get "/first_list.json"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        last_response.body.should == @list.to_json
      end
    end
    
    context "requesting list that doesn't exist" do
      it "should not find xml list" do
        get "/non_existant_list.xml"
        last_response.should be_not_found
      end

      it "should not find json list" do
        get "/non_existant_list.json"
        last_response.should be_not_found
      end
    end
  end
  
  describe "search" do
    describe "GET to /search" do
     context "with a query" do
        before do
          @articles = (1..2).collect do |n|
            Factory :detailed_article, 
                    :published_at => n.hours.ago, 
                    :account => @account
          end
          Article.stub!(:search).and_return(@articles)
        end
      
        it "should return an XML array of only published, matching articles" do
          get "/search.xml?q=chicago"
          
          articles = @account.articles.published.
                              search( "chicago", 
                                      :order => "published_at desc",
                                      :limit => 20)
          pagination_options = { :page => 1, :per_page => 20 }
          
          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == Builder::XmlMarkup.new.search_results do |xml|
             articles.each { |article| xml <<  article.to_xml }
          end
        end
        
        it "should return an JSON array of only published, matching articles" do
          get "/search.json?q=chicago"

          pagination_options = { :page => 1, :per_page => 20 }
          last_response.should be_ok
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
          Yajl::Parser.parse(last_response.body).should be_an(Array)                               
        end
      end
      
      context "without a query" do
        it "should return an empty xml array" do
          get "/search.xml"

          last_response.should be_ok
          last_response.headers['Content-Type'].should == "text/xml;charset=utf-8"
          last_response.body.should == Builder::XmlMarkup.new.search_results
        end
      end
     end
  end
  
  describe "jsonp" do
    it "should support jsonp on all json end points" do
      callback = "jsonpcallbackfunction"
      article = Factory(:detailed_article, :account => @account)
 
      get "/articles/#{article.to_param}.json?callback=#{callback}"

      last_response.should be_ok
      last_response.body.should == "#{callback}(" + article.to_json + ")"
      
      list = Factory :list, :name => "First list", :account => @account
      list.documents = (1..3).collect { Factory(:published_article, :account => @account) }
      
      get "/first_list.json?callback=#{callback}"
      
      last_response.should be_ok
      last_response.body.should == "#{callback}(" + list.to_json + ")"
    end
  end

end