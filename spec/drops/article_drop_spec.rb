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
  
  describe "section" do
    before do
      @article = Factory(:article)
    end
    
    it "should know article's section's name" do
      category = Factory(:category, :name => "News-ish", :account => @article.account)
      @article.update_attribute(:section, category)
      output = Liquid::Template.parse( ' {{ article.section }} '  ).render('article' => ArticleDrop.new(@article))
      output.should == " News-ish "
    end
    
    it "should return nothing when no name is set" do
      output = Liquid::Template.parse( ' {{ article.section }} '  ).render('article' => ArticleDrop.new(@article))
      output.should == "  "
    end
  end
  
  describe "categories" do
    before do
      @article_with_categories = Factory(:article)
      @categories = (1..3).collect{ Factory(:category, :account => @article_with_categories.account) }
      
      @article_with_categories.categories << @categories
    end
    
    it "should return the article's categories" do
      output = Liquid::Template.parse( ' {% for category in article.categories %} {{ category.name }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article_with_categories))
    
      names = @article_with_categories.categories.collect{ |a|  a.name }
      output.should == "  #{names.join('  ')}  "
    end
  end
  
  describe "dates" do
    context "for published article" do
      it "should make relevant dates available in a variety of formats" do
        output = Liquid::Template.parse( ' {{ article.published_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.published_at.to_s(:standard).gsub(' ', '&nbsp;')} "
  
        output = Liquid::Template.parse( ' {{ article.published_at_detailed | date: "%b %e, %G at %l:%M %P" }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.published_at.to_datetime.strftime("%b %e, %G at %l:%M %P")} "

        output = Liquid::Template.parse( ' {{ article.updated_at }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.updated_at.to_s(:standard).gsub(' ', '&nbsp;')} "  
    
        output = Liquid::Template.parse( ' {{ article.updated_at_detailed | date: "%b %e, %G at %l:%M %P" }} '  ).render('article' => ArticleDrop.new(@article))
        output.should == " #{@article.updated_at.to_datetime.strftime("%b %e, %G at %l:%M %P")} "  
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
    output.should == " /articles/#{@article.id} "
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
    
    it "should return the article's authors list with links" do
      @account = Factory(:account)
      output = Liquid::Template.parse( '  {{ article.authors_list_with_links }}  '  ).render({'article' => ArticleDrop.new(@article_with_authors)} )
      output.should == "  <a href=\"/search?q=#{CGI.escape(@authors[0].name)}&amp;page=1\">#{@authors[0].name}</a>, <a href=\"/search?q=#{CGI.escape(@authors[1].name)}&amp;page=1\">#{@authors[1].name}</a> and <a href=\"/search?q=#{CGI.escape(@authors[2].name)}&amp;page=1\">#{@authors[2].name}</a>  "
 
      article_with_two_authors = Factory(:article, :authors => @authors[0..1])
      output = Liquid::Template.parse( '  {{ article.authors_list_with_links }}  '  ).render({'article' => ArticleDrop.new(article_with_two_authors)})
      output.should == "  <a href=\"/search?q=#{CGI.escape(@authors[0].name)}&amp;page=1\">#{@authors[0].name}</a> and <a href=\"/search?q=#{CGI.escape(@authors[1].name)}&amp;page=1\">#{@authors[1].name}</a>  "

      article_with_one_author = Factory(:article, :authors => [@authors[0]])
      output = Liquid::Template.parse( '  {{ article.authors_list_with_links }}  '  ).render({'article' => ArticleDrop.new(article_with_one_author)} )
      output.should == "  <a href=\"/search?q=#{CGI.escape(@authors[0].name)}&amp;page=1\">#{@authors[0].name}</a>  "
      
      article_with_no_authors = Factory(:article)
      output = Liquid::Template.parse( '  {{ article.authors_list_with_links }}  '  ).render('article' => ArticleDrop.new(article_with_no_authors))
      output.should == "    "
    end
  end

  describe "tags" do
    before do
      @tags = (1..3).collect{ |n| "Tag #{n}" }
      @article_with_tags = Factory(:article)
      @article_with_tags.stub!(:tag_list).and_return(@tags)
    end
    
    it "should return the article's tags" do
      output = Liquid::Template.parse( ' {% for tag in article.tags %} {{ tag }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article_with_tags))
    
      names = @article_with_tags.tag_list
      output.should == "  #{names.join('  ')}  "
    end
    
    it "should return the article's tags list" do
      output = Liquid::Template.parse( '  {{ article.tags_list }}  '  ).render('article' => ArticleDrop.new(@article_with_tags))
      output.should == "  #{@tags[0]}, #{@tags[1]}, #{@tags[2]}  "
      
      article_with_two_tags = Factory(:article)
      article_with_two_tags.stub!(:tag_list).and_return(@tags[0..1])
      output = Liquid::Template.parse( '  {{ article.tags_list }}  '  ).render('article' => ArticleDrop.new(article_with_two_tags))
      output.should == "  #{@tags[0]}, #{@tags[1]}  "
      
      article_with_one_tag = Factory(:article)
      article_with_one_tag.stub!(:tag_list).and_return([@tags[0]])
      output = Liquid::Template.parse( '  {{ article.tags_list }}  '  ).render('article' => ArticleDrop.new(article_with_one_tag))
      output.should == "  #{@tags[0]}  "  
      
      article_with_no_tags = Factory(:article)
      output = Liquid::Template.parse( '  {{ article.tags_list }}  '  ).render('article' => ArticleDrop.new(article_with_no_tags))
      output.should == "    "    
    end
    
    it "should return the article's tags list, with links to tag search" do
      @account = Factory(:account)
      output = Liquid::Template.parse( '  {{ article.tags_list_with_links }}  '  ).render({'article' => ArticleDrop.new(@article_with_tags)}, :registers => {:account => @account} )
      output.should == "  <a href=\"/search?q=#{CGI.escape(@tags[0])}&amp;page=1\">#{@tags[0]}</a>, <a href=\"/search?q=#{CGI.escape(@tags[1])}&amp;page=1\">#{@tags[1]}</a>, <a href=\"/search?q=#{CGI.escape(@tags[2])}&amp;page=1\">#{@tags[2]}</a>  "
 
      article_with_two_tags = Factory(:article)
      article_with_two_tags.stub!(:tag_list).and_return(@tags[0..1])
      output = Liquid::Template.parse( '  {{ article.tags_list_with_links }}  '  ).render({'article' => ArticleDrop.new(article_with_two_tags)}, :registers => {:account => @account} )
      output.should == "  <a href=\"/search?q=#{CGI.escape(@tags[0])}&amp;page=1\">#{@tags[0]}</a>, <a href=\"/search?q=#{CGI.escape(@tags[1])}&amp;page=1\">#{@tags[1]}</a>  "

      article_with_one_tag = Factory(:article)
      article_with_one_tag.stub!(:tag_list).and_return([@tags[0]])
      output = Liquid::Template.parse( '  {{ article.tags_list_with_links }}  '  ).render({'article' => ArticleDrop.new(article_with_one_tag)}, :registers => {:account => @account} )
      output.should == "  <a href=\"/search?q=#{CGI.escape(@tags[0])}&amp;page=1\">#{@tags[0]}</a>  "
      
      article_with_no_tags = Factory(:article)
      output = Liquid::Template.parse( '  {{ article.tags_list_with_links }}  '  ).render('article' => ArticleDrop.new(article_with_no_tags))
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

        urls = @article_with_some_images.images.collect{ |i|  i.url(:original) }
        output.should == "  #{urls.join('  ')}  "    
      end
      
      it "should know whether the article has an attached image" do
        template = Liquid::Template.parse( ' {% if article.has_image? %} YES {% else %} NO {% endif %} ')

        output = template.render('article' => ArticleDrop.new(@article))
        output.should eql("  NO  ")

        output = template.render('article' => ArticleDrop.new(@article_with_some_images))
        output.should eql("  YES  ")
      end
      
      describe "by proportions" do
        it "should know whether the article has a vertical image" do
          article_with_vertical_image = Factory(:article, :mediafiles => [Factory(:vertical_image)])
          output = Liquid::Template.parse( '{% if article.has_vertical_image? %} PASS {% else %} FAIL {% endif %}'  ).render('article' => ArticleDrop.new(article_with_vertical_image))
          output.should == " PASS "

          article_without_vertical_image = Factory(:article, :mediafiles => [Factory(:horizontal_image)])
          output = Liquid::Template.parse( '{% if article.has_vertical_image? %} PASS {% else %} FAIL {% endif %}'  ).render('article' => ArticleDrop.new(article_without_vertical_image))
          output.should == " FAIL "
        end

        it "should know whether the article has a horizontal image" do
          article_with_horizontal_image = Factory(:article, :mediafiles => [Factory(:horizontal_image)])
          output = Liquid::Template.parse( '{% if article.has_horizontal_image? %} PASS {% else %} FAIL {% endif %}'  ).render('article' => ArticleDrop.new(article_with_horizontal_image))
          output.should == " PASS "

          article_without_horizontal_image = Factory(:article, :mediafiles => [Factory(:vertical_image)])
          output = Liquid::Template.parse( '{% if article.has_horizontal_image? %} PASS {% else %} FAIL {% endif %}'  ).render('article' => ArticleDrop.new(article_without_horizontal_image))
          output.should == " FAIL "
        end

        it "should return the first vertical image" do
          image = Factory(:vertical_image)
          article = Factory(:article, :mediafiles =>[Factory(:mediafile), Factory(:horizontal_image), image])
          output = Liquid::Template.parse( ' {{ article.first_vertical_image.title }} '  ).render('article' => ArticleDrop.new(article))
          output.should == " #{image.title} "
        end

        it "should return the first horizontal image" do
          image = Factory(:horizontal_image)
          article = Factory(:article, :mediafiles =>[Factory(:mediafile), Factory(:vertical_image), image])
          output = Liquid::Template.parse( ' {{ article.first_horizontal_image.title }} '  ).render('article' => ArticleDrop.new(article))
          output.should == " #{image.title} "
        end
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
      @comments = (1..3).collect { |n| Factory(:comment, :name => "Commentor ##{n}", :created_at => n.days.ago, :document => @article) }
    end
    
    it "should know whether the article has any comments" do
      template = Liquid::Template.parse( ' {% if article.has_comments? %} YES {% else %} NO {% endif %} ')

      output = template.render('article' => ArticleDrop.new(@article))
      output.should eql("  YES  ")
      
      @article.comments.clear
      output = template.render('article' => ArticleDrop.new(@article))
      output.should eql("  NO  ")
    end
        
    it "should make comments available oldest first" do
      output = Liquid::Template.parse( ' {% for comment in article.comments %} {{ comment.name }} {% endfor %} '  ).render('article' => ArticleDrop.new(@article))
      output.should == "  #{ @comments.reverse.collect{|c| c.name }.join('  ') }  "
    end
    
    it "should know its current comment count" do
      output = Liquid::Template.parse( '  {{ article.comment_count }}  '  ).render('article' => ArticleDrop.new(@article))
      output.should == "  3  "
    end
    
    describe "comment status" do
      describe "locked comments" do
        it "should show as locked when set as locked" do
          @article.lock_comments
          
          output = Liquid::Template.parse( '{% if article.comments_locked %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " YES "
        end

        it "should show as unlocked when set as unlocked" do
          @article.enable_comments
          
          output = Liquid::Template.parse( '{% if article.comments_locked %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " NO "
        end

        it "should show as unlocked when not set" do
          output = Liquid::Template.parse( '{% if article.comments_locked %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " NO "
        end
      end

      describe "disabled comments" do
        it "should show as enabled when set as enabled" do
          @article.enable_comments

          output = Liquid::Template.parse( '{% if article.comments_enabled %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " YES "
        end

        it "should show as enabled when not set" do
          output = Liquid::Template.parse( '{% if article.comments_enabled %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " YES "
        end

        it "should show as disabled when set as disabled" do
          @article.disable_comments
          
          output = Liquid::Template.parse( '{% if article.comments_enabled %} YES {% else %} NO {% endif %}'  ).render('article' => ArticleDrop.new(@article))
          output.should == " NO "
        end
      end
    end
  end
end
