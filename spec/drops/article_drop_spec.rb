require 'spec_helper'

describe ArticleDrop do
  before do
    @article = Factory(:published_article, :title => "Title", :subtitle => "Subtitle", :bodytext => "this is the **real** thing.")
  end
  
  it "should make basic article data available" do
    output = Liquid::Template.parse( ' {{ article.id }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " #{@article.id} "

    output = Liquid::Template.parse( ' {{ article.title }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " #{@article.title} "
    
    output = Liquid::Template.parse( ' {{ article.subtitle }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " #{@article.subtitle} "
    
    output = Liquid::Template.parse( ' {{ article.bodytext }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " #{@article.bodytext} "
  end
  
  describe "dates" do
    context "for published article" do
      it "should make relevant dates available in a variety of formats" do
        output = Liquid::Template.parse( ' {{ article.published_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.published_at.to_s(:standard).gsub(' ', '&nbsp;')} "
  
        output = Liquid::Template.parse( ' {{ article.published_at_detailed }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.published_at.to_s(:long)} "

        output = Liquid::Template.parse( ' {{ article.updated_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.updated_at.to_s(:standard).gsub(' ', '&nbsp;')} "  
    
        output = Liquid::Template.parse( ' {{ article.updated_at_detailed }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.updated_at.to_s(:long)} "  
      end
    end
    
    context "for draft article" do
      before do
        @article.unpublish
      end
      
      it "should note that this is a draft article" do
        output = Liquid::Template.parse( ' {{ article.published_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should match(/Draft/i)
        
        output = Liquid::Template.parse( ' {{ article.published_at_detailed }} '  ).render('article' => ArticleDrop.new(@article))
        output.should match(/Draft/i)
      end
    end
    
    context "for scheduled article" do
      before do
        @article = Factory(:scheduled_article)
      end
      
      it "should note that this is a scheduled article" do
        output = Liquid::Template.parse( ' {{ article.published_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should match(/Will be available/i)
        
        output = Liquid::Template.parse( ' {{ article.published_at_detailed }} '  ).render('article' => ArticleDrop.new(@article))
        output.should match(/Will be available/i)
      end
    end
  end  
    
  it "should return the article's url" do
    output = Liquid::Template.parse( ' {{ article.url }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " /accounts/#{@article.account.id}/articles/#{@article.id} "
  end
    
  it "should know the article's wordcount" do
    output = Liquid::Template.parse( ' {{ article.word_count }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " #{@article.word_count} "    
  end

  describe "authors" do
    before do
      @authors = (1..3).collect{ Factory(:author) }
      @article_with_authors = Factory(:article, :authors => @authors)
    end
    
    it "should return the article's authors" do
      output = Liquid::Template.parse( ' {% for author in article.authors %} {{ author.name }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article_with_authors))
    
      names = @article_with_authors.authors.collect{ |a|  a.name }
      output.should == "  #{names.join('  ')}  "
    end
    
    it "should return the article's authors list" do
      output = Liquid::Template.parse( '  {{ article.authors_list }}  '  ).render('article' => ArticleDrop.new(@article_with_authors))
      output.should == "  #{@article_with_authors.authors_list}  "
      
      article_with_no_authors = Factory(:article)
      output = Liquid::Template.parse( '  {{ article.authors_list }}  '  ).render('article' => ArticleDrop.new(article_with_no_authors))
      output.should == "    "
    end
  end

  describe "mediafiles" do
    describe "images" do
        before do
          @images = (1..3).collect{ Factory(:image) }
          @article_with_some_images = Factory(:article, :mediafiles => ((1..3).collect{ Factory(:mediafile) } + @images))
        end

        it "should return the article's images" do
          output = Liquid::Template.parse( ' {% for image in article.images %} {{ image.url }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article_with_some_images))

          urls = @article_with_some_images.images.collect{ |i|  i.url }
          output.should == "  #{urls.join('  ')}  "    
        end
        
        it "should know whether the article has an attached image" do
          template = Liquid::Template.parse( ' {% if article.has_image? %} YES {% else %} NO {% endif %} ')

          output = template.render('article' => ArticleDrop.new(@article))
          output.should eql("  NO  ")

          output = template.render('article' => ArticleDrop.new(@article_with_some_images))
          output.should eql("  YES  ")
        end
    end
    
    describe "mediafile caption" do
      before do
        @mediafile = Factory(:image)
        @article = Factory(:article)
        @waxing = Waxing.create!(:mediafile_id => @mediafile.id, :document_id => @article.id, :caption => "Caption for testing.")
      end
      
      it "should return the article's images" do
        output = Liquid::Template.parse( ' {{ article.images.first.caption }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@waxing.caption} "
      end
    end
  end
  
  describe "summary" do
    it "should return article summary, if present" do
      @article.summary = "This is the article summary"
      output = Liquid::Template.parse( ' {{ article.excerpt }} '  ).render('article' => ArticleDrop.new(@article))
      output.should == " #{ @article.summary } "
    end
    
    it "should generate an article excerpt from bodytext if none is provided" do
      @article.summary = ""
      output = Liquid::Template.parse( ' {{ article.excerpt }} '  ).render('article' => ArticleDrop.new(@article))
      output.should == " #{ @article.bodytext } "
    end
    
    it "should shorten bodytext for excerpt if bodytext is longer than 120 words" do
      @article.bodytext = (1..13).collect{ "This demo sentance is just a simple ten word phrase." }.join(' ')
      expected_bodytext = (1..12).collect{ "This demo sentance is just a simple ten word phrase." }.join(' ') + "…"
      
      output = Liquid::Template.parse( ' {{ article.excerpt }} '  ).render('article' => ArticleDrop.new(@article))
      output.should == " #{ expected_bodytext } "
    end
  end
  
  describe "comments" do
    before do
      pending "addition of comments"
      @comments = (1..3).collect { |n| Factory(:comment, :name => "Commentor ##{n}", :created_at => n.days.ago, :article => @article) }
    end
    
    it "should make comments available oldest first" do
      output = Liquid::Template.parse( ' {% for comment in article.comments %} {{ comment.name }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article))
      output.should == "  #{ @comments.reverse.collect{|c| c.name }.join('  ') }  "
    end
  end
end
