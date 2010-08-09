require 'spec_helper'

describe LinkFilters do
  before do
    @design = Factory(:design)
  end
  
  describe "link tags" do 
     describe "link to front page" do
      context "when viewing current design" do
        before do
          @design.make_current
        end

         it "should return link to front page with string" do
           output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_front_page }} "  ).render({}, :registers => { :design => @design })
           output.should == " <a href=\"/\">A string to link</a> "
         end
       end

       context "when previewing a design other than the current one" do
         it "should insert design id into query string when building links" do
           output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_front_page }} "  ).render({}, :registers => { :design => @design })
           output.should == " <a href=\"/?design_id=#{@design.id}\">A string to link</a> "
         end
       end
     end
      
     describe "link to article" do
       context "when viewing current design" do
         before do
           @design.make_current
         end
       
          it "should return link to article with article as first parameters" do
            article = Factory(:article, :title => "Testing title")
            output = Liquid::Template.parse( " {{ article | link_to_article }} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => @design })
            output.should == " <a href=\"/articles/#{article.id}\">#{article.title}</a> "
          end
        
          it "should return link to article with string as first parameter and article as second" do
            article = Factory(:article)
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_article: article }} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => @design })
            output.should == " <a href=\"/articles/#{article.id}\">A string to link</a> "
          end
        
          it "should return link to article with article as first parameter and string as second" do
            article = Factory(:article)
            output = Liquid::Template.parse( " {{ article | link_to_article:\"A string to link\" }} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => @design })
            output.should == " <a href=\"/articles/#{article.id}\">A string to link</a> "
          end
        end
      
        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            article = Factory(:article, :title => "Testing title")
            output = Liquid::Template.parse( " {{ article | link_to_article }} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => @design })
            output.should == " <a href=\"/articles/#{article.id}?design_id=#{@design.id}\">#{article.title}</a> "
          end
        end
     end

     describe "link to blog" do
       context "when viewing current design" do
         before do
           @design.make_current
         end
       
          it "should return link to blog with blog as first parameters" do
            blog = Factory(:blog)
            output = Liquid::Template.parse( " {{ blog | link_to_blog }} "  ).render({'blog' => BlogDrop.new(blog)}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs/#{blog.slug}\">#{blog.title}</a> "
          end
        
          it "should return link to blog with string as first parameter and blog as second" do
            blog = Factory(:blog)
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_blog: blog }} "  ).render({'blog' => BlogDrop.new(blog)}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs/#{blog.slug}\">A string to link</a> "
          end
        
          it "should return link to article with article as first parameter and string as second" do
            blog = Factory(:blog)
            output = Liquid::Template.parse( " {{ blog | link_to_blog:\"A string to link\" }} "  ).render({'blog' => BlogDrop.new(blog)}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs/#{blog.slug}\">A string to link</a> "
          end
        end
      
        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            blog = Factory(:blog)
            output = Liquid::Template.parse( " {{ blog | link_to_blog }} "  ).render({'blog' => BlogDrop.new(blog)}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs/#{blog.slug}?design_id=#{@design.id}\">#{blog.title}</a> "
          end
        end
     end
      
     describe "link to blogs" do
       context "when viewing current design" do
         before do
           @design.make_current
         end
        
          it "should return link to blog with string" do
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_blogs }} "  ).render({}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs\">A string to link</a> "
          end
        end
      
        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_blogs }} "  ).render({}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs?design_id=#{@design.id}\">A string to link</a> "
          end
        end
     end
      
     describe "link to entry" do
        context "when viewing current design" do
          before do
           @design.make_current
          end

           it "should return link to entry with entry as first parameters" do
             entry = Factory(:entry)
             output = Liquid::Template.parse( " {{ entry | link_to_entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
             output.should == " <a href=\"/blogs/#{entry.blog.slug}/#{entry.id}\">#{entry.title}</a> "
           end

           it "should return link to entry with string as first parameter and entry as second" do
             entry = Factory(:entry)
             output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_entry: entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
             output.should == " <a href=\"/blogs/#{entry.blog.slug}/#{entry.id}\">A string to link</a> "
           end

           it "should return link to entry with entry as first parameter and string as second" do
             entry = Factory(:entry)
             output = Liquid::Template.parse( " {{ entry | link_to_entry:\"A string to link\" }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
             output.should == " <a href=\"/blogs/#{entry.blog.slug}/#{entry.id}\">A string to link</a> "
           end
        end

        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            entry = Factory(:entry)
            output = Liquid::Template.parse( " {{ entry | link_to_entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
            output.should == " <a href=\"/blogs/#{entry.blog.slug}/#{entry.id}?design_id=#{@design.id}\">#{entry.title}</a> "
          end
        end
     end
  
     describe "link to page" do
        context "when viewing current design" do
           before do
             @design.make_current
           end
         
           it "should return link to entry with entry as first parameters" do
             page = Factory(:page)
             output = Liquid::Template.parse( " {{ page | link_to_page }} "  ).render({'page' => PageDrop.new(page)}, :registers => { :design => @design })
             output.should == " <a href=\"/pages#{page.url}\">#{page.name}</a> "
           end
         
           it "should return link to page with string as first parameter and page as second" do
             page = Factory(:page)
             output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_page: page }} "  ).render({'page' => PageDrop.new(page)}, :registers => { :design => @design })
             output.should == " <a href=\"/pages#{page.url}\">A string to link</a> "
           end

           it "should return link to page with page as first parameter and string as second" do
             page = Factory(:page)
             output = Liquid::Template.parse( " {{ page | link_to_page:\"A string to link\" }} "  ).render({'page' => PageDrop.new(page)}, :registers => { :design => @design })
             output.should == " <a href=\"/pages#{page.url}\">A string to link</a> "
           end
         end
       
         context "when previewing a design other than the current one" do
           it "should insert design id into query string when building links" do
             page = Factory(:page)
             output = Liquid::Template.parse( " {{ page | link_to_page }} "  ).render({'page' => PageDrop.new(page)}, :registers => { :design => @design })
             output.should == " <a href=\"/pages#{page.url}?design_id=#{@design.id}\">#{page.name}</a> "
           end
         end
     end
   
     describe "link to category" do
        context "when viewing current design" do
           before do
             @design.make_current
           end
         
           it "should return link to category with category as first parameters" do
             category = Factory(:category)
             output = Liquid::Template.parse( " {{ category | link_to_category }} "  ).render({'category' => CategoryDrop.new(category)}, :registers => { :design => @design })
             output.should == " <a href=\"/categories#{category.path}\">#{category.name}</a> "
           end
         
           it "should return link to category with string as first parameter and category as second" do
             category = Factory(:category)
             output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_category: category }} "  ).render({'category' => CategoryDrop.new(category)}, :registers => { :design => @design })
             output.should == " <a href=\"/categories#{category.path}\">A string to link</a> "
           end

           it "should return link to category with category as first parameter and string as second" do
             category = Factory(:category)
             output = Liquid::Template.parse( " {{ category | link_to_category:\"A string to link\" }} "  ).render({'category' => CategoryDrop.new(category)}, :registers => { :design => @design })
             output.should == " <a href=\"/categories#{category.path}\">A string to link</a> "
           end
         end
       
         context "when previewing a design other than the current one" do
           it "should insert design id into query string when building links" do
             category = Factory(:category)
             output = Liquid::Template.parse( " {{ category | link_to_category }} "  ).render({'category' => CategoryDrop.new(category)}, :registers => { :design => @design })
             output.should == " <a href=\"/categories#{category.path}?design_id=#{@design.id}\">#{category.name}</a> "
           end
         end
     end
      
     describe "link to issue" do
       context "when viewing current design" do
         before do
           @design.make_current
         end
       
          it "should return link to issue with issue as first parameters" do
            issue = Factory(:issue)
            output = Liquid::Template.parse( " {{ issue | link_to_issue }} "  ).render({'issue' => IssueDrop.new(issue)}, :registers => { :design => @design })
            output.should == " <a href=\"/issues/#{issue.id}\">#{issue.date.strftime(%"%B %e, %Y")}</a> "
          end
        
          it "should return link to issue with string as first parameter and issue as second" do
            issue = Factory(:issue)
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_issue: issue }} "  ).render({'issue' => IssueDrop.new(issue)}, :registers => { :design => @design })
            output.should == " <a href=\"/issues/#{issue.id}\">A string to link</a> "
          end
        
          it "should return link to article with article as first parameter and string as second" do
            issue = Factory(:issue)
            output = Liquid::Template.parse( " {{ issue | link_to_issue:\"A string to link\" }} "  ).render({'issue' => IssueDrop.new(issue)}, :registers => { :design => @design })
            output.should == " <a href=\"/issues/#{issue.id}\">A string to link</a> "
          end
        end
      
        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            issue = Factory(:issue)
            output = Liquid::Template.parse( " {{ issue | link_to_issue }} "  ).render({'issue' => IssueDrop.new(issue)}, :registers => { :design => @design })
            output.should == " <a href=\"/issues/#{issue.id}?design_id=#{@design.id}\">#{issue.date.strftime(%"%B %e, %Y")}</a> "
          end
        end
     end

     describe "link to issues" do
       context "when viewing current design" do
         before do
           @design.make_current
         end
        
          it "should return link to issues with string" do
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_issues }} "  ).render({}, :registers => { :design => @design })
            output.should == " <a href=\"/issues\">A string to link</a> "
          end
        end
      
        context "when previewing a design other than the current one" do
          it "should insert design id into query string when building links" do
            output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_issues }} "  ).render({}, :registers => { :design => @design })
            output.should == " <a href=\"/issues?design_id=#{@design.id}\">A string to link</a> "
          end
        end
     end
  
     describe "link to search" do
      context "when viewing current design" do
        before do
          @design.make_current
        end

         it "should return link to search with string" do
           output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_search }} "  ).render({}, :registers => { :design => @design })
           output.should == " <a href=\"/search\">A string to link</a> "
         end
       end

       context "when previewing a design other than the current one" do
         it "should insert design id into query string when building links" do
           output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_search }} "  ).render({}, :registers => { :design => @design })
           output.should == " <a href=\"/search?design_id=#{@design.id}\">A string to link</a> "
         end
       end
     end
  end
  
end
