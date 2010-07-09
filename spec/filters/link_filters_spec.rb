require 'spec_helper'

describe LinkFilters do
  before do
    @design = Factory(:design)
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
      
   describe "link to entry" do
      context "when viewing current design" do
        before do
         @design.make_current
        end

         it "should return link to entry with entry as first parameters" do
           entry = Factory(:entry)
           output = Liquid::Template.parse( " {{ entry | link_to_entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
           output.should == " <a href=\"/blogs/#{entry.blog.slug}/entries/#{entry.id}\">#{entry.title}</a> "
         end

         it "should return link to entry with string as first parameter and entry as second" do
           entry = Factory(:entry)
           output = Liquid::Template.parse( " {{ \"A string to link\" | link_to_entry: entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
           output.should == " <a href=\"/blogs/#{entry.blog.slug}/entries/#{entry.id}\">A string to link</a> "
         end

         it "should return link to entry with entry as first parameter and string as second" do
           entry = Factory(:entry)
           output = Liquid::Template.parse( " {{ entry | link_to_entry:\"A string to link\" }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
           output.should == " <a href=\"/blogs/#{entry.blog.slug}/entries/#{entry.id}\">A string to link</a> "
         end
      end

      context "when previewing a design other than the current one" do
        it "should insert design id into query string when building links" do
          entry = Factory(:entry)
          output = Liquid::Template.parse( " {{ entry | link_to_entry }} "  ).render({'entry' => EntryDrop.new(entry)}, :registers => { :design => @design })
          output.should == " <a href=\"/blogs/#{entry.blog.slug}/entries/#{entry.id}?design_id=#{@design.id}\">#{entry.title}</a> "
        end
      end
   end
  
   describe "link to page" do
     before do
       pending "Addition of pages"
     end
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
end
