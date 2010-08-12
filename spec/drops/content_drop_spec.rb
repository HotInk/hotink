require 'spec_helper'

describe ContentDrop do
  before do
    @account = Factory(:account)
  end
  
  describe "categories" do
    before do
      @categories = (1..2).collect{ Factory(:category, :account => @account) }
    end
    
    it "should return categories" do
      output = Liquid::Template.parse( ' {% for category in content.categories %} {{ category.name }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ @categories.collect{ |c| c.name }.join('  ') }  "
    end     
    
    it "should return a specific category by name" do
      output = Liquid::Template.parse(" {{ content.category[\"#{@categories[0].name}\"].name }} ").render('content' => ContentDrop.new(@account))
      output.should == " #{ @categories[0].name } "
    end 
  end
  
  describe "pages" do
    before do
      @pages = (1..2).collect{ |n| Factory(:page, :contents => "Page ##{n}", :account => @account) }
      @subpages = (1..2).collect{ |n|  Factory(:page, :contents => "Page ##{n}", :parent => @pages[0], :account => @account) }
    end
    
    it "should return top-level pages" do
      output = Liquid::Template.parse( ' {% for page in content.pages %} {{ page.raw_contents }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ @pages.collect{ |p| p.contents }.join('  ') }  "
    end     
    
    it "should return a specific page by url" do
      output = Liquid::Template.parse(" {{ content.page[\"#{@subpages[0].url}\"].raw_contents }} ").render('content' => ContentDrop.new(@account))
      output.should == " #{ @subpages[0].contents } "
    end 
  end
  
  describe "issues" do
    before do
      @issues = (1..22).collect { |n|  Factory(:issue, :date => 10.weeks.ago + n.weeks, :name => "Issue ##{n}", :account => @account) }
    end
    
    it "should return latest issue" do
      output = Liquid::Template.parse(" {{ content.latest_issue.name }} ").render('content' => ContentDrop.new(@account))
      output.should == " #{ @issues.last.name } "
    end
    
    describe "issue pagination" do
      it "should return 20 entries on first page by default" do
        output = Liquid::Template.parse( ' {% for issue in content.issues %} {{ issue.name }} {% endfor %} {{ content.issues.total_entries }}'  ).render('content' => ContentDrop.new(@account))
        output.should == "  #{ @issues.reverse[0...20].collect{ |i| i.name }.join('  ') }  "
      end

      it "should return page 2" do
        output = Liquid::Template.parse( ' {% for issue in content.issues %} {{ issue.name }} {% endfor %} '  ).render({'content' => ContentDrop.new(@account)}, :registers => { :page => 2 } )
        output.should == "  #{ @issues.reverse[20..21].collect{ |i| i.name }.join('  ') }  "
      end

      it "should return 2 entries per page" do
        output = Liquid::Template.parse( ' {% for issue in content.issues %} {{ issue.name }} {% endfor %} '  ).render({'content' => ContentDrop.new(@account)}, :registers => { :per_page => 2 } )
        output.should == "  #{ @issues.reverse[0...2].collect{ |i| i.name }.join('  ') }  "
      end
    end
  end
  
  describe "articles" do
    before do
      @drafts = (1..3).collect { |n|  Factory(:draft_article) }
      @articles = (1..22).collect { |n|  Factory(:published_article, :published_at => 10.weeks.ago + n.days, :title => "Article ##{n}", :account => @account) }
    end

    it "should return latest article" do
      output = Liquid::Template.parse(" {{ content.latest_article.title }} ").render('content' => ContentDrop.new(@account))
      output.should == " #{ @articles.last.title } "
    end

    describe "article pagination" do
      it "should return 20 entries on first page by default" do
        output = Liquid::Template.parse( ' {% for article in content.articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
        output.should == "  #{ @articles.reverse[0...20].collect{ |i| i.title }.join('  ') }  "
      end

      it "should return page 2" do
        output = Liquid::Template.parse( ' {% for article in content.articles %} {{ article.title }} {% endfor %} '  ).render({'content' => ContentDrop.new(@account)}, :registers => { :page => 2 } )
        output.should == "  #{ @articles.reverse[20..21].collect{ |i| i.title }.join('  ') }  "
      end

      it "should return 10 entries per page" do
        output = Liquid::Template.parse( ' {% for article in content.articles %} {{ article.title }} {% endfor %} '  ).render({'content' => ContentDrop.new(@account)}, :registers => { :per_page => 10 } )
        output.should == "  #{ @articles.reverse[0...10].collect{ |i| i.title }.join('  ') }  "
      end
    end
  end
  
  describe "blogs" do
    before do
      @blogs = (1..2).collect{ |n|  Factory(:blog, :title => "Blog ##{n}", :account => @account) }
    end

    it "should return blogs" do
      output = Liquid::Template.parse( ' {% for blog in content.blogs %} {{ blog.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ @blogs.collect{ |b| b.title }.join('  ') }  "
    end     

    it "should return a specific category by slug" do
      output = Liquid::Template.parse(" {{ content.blog[\"#{@blogs[0].slug}\"].title }} ").render('content' => ContentDrop.new(@account))
      output.should == " #{ @blogs[0].title } "
    end 
  end
  
  describe "lead articles" do
    before do
      @lead_articles = (1..5).collect{ |n| Factory(:published_article, :title => "Title ##{n}", :account => @account) }
      @account.update_attribute :lead_article_ids, @lead_articles.collect{ |article| article.id  }
    end

    it "should return lead articles" do
      output = Liquid::Template.parse( ' {% for article in content.lead_articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ @lead_articles.collect{ |a| a.title }.join('  ') }  "
    end

    it "should leave out unpublished articles" do
      @lead_articles[0].unpublish!
  
      output = Liquid::Template.parse( ' {% for article in content.lead_articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ @lead_articles[1..-1].collect{ |a| a.title }.join('  ') }  "
    end

    it "should return an alternate set of lead articles for previewing, if supplied" do
      preview_lead_articles = (1..2).collect{ |n| Factory(:published_article, :title => "Title ##{n}", :account => @account) }
  
      output = Liquid::Template.parse( ' {% for article in content.lead_articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account, :preview_lead_article_ids => preview_lead_articles.collect{ |a| a.id }))
      output.should == "  #{ preview_lead_articles.collect{ |a| a.title }.join('  ') }  "
    end
    
    it "should return empty array when no lead articles are set" do
      @account.update_attribute :lead_article_ids, nil
      output = Liquid::Template.parse( ' {% for article in content.lead_articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  "
    end
  end
  
  describe "list support" do
    it "should return list drops as though each list's slug was an instance method" do
      list = Factory(:list, :name => "First list", :account => @account)
      
      output = Liquid::Template.parse( '  {{ content.first_list.name }}  '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ list.name }  "
    end

    it "should return list articles" do
      list = Factory(:list, :name => "Second article-list", :account => @account)
      articles = (1..4).collect{ |n| Factory(:published_article, :title => "Title ##{n}") }
      list.documents = articles
      
      output = Liquid::Template.parse( ' {% for article in content.second_article_list.articles %} {{ article.title }} {% endfor %} '  ).render('content' => ContentDrop.new(@account))
      output.should == "  #{ articles.collect{ |a| a.title }.join('  ') }  "
    end
    
    it "should return sensible error if no list exists" do
      output = Liquid::Template.parse( '  {{ content.non_existant_list }}  '  ).render('content' => ContentDrop.new(@account))
      output.should == "  <span class=\"liquid_error\">No data named 'non_existant_list' in ContentDrop</span>  "
    end
  end
end
