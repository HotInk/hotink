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