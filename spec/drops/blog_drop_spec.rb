require 'spec_helper'

describe BlogDrop do
  before do
    @blog = Factory(:blog, :title => "Title", :description => "this is the **real** description.")
  end
  
  it "should make basic blog data available" do
    output = Liquid::Template.parse( ' {{ blog.id }} '  ).render('blog' => BlogDrop.new(@blog))
    output.should == " #{@blog.id} "

    output = Liquid::Template.parse( ' {{ blog.title }} '  ).render('blog' => BlogDrop.new(@blog))
    output.should == " #{@blog.title} "
    
    output = Liquid::Template.parse( ' {{ blog.description }} '  ).render('blog' => BlogDrop.new(@blog))
    output.should == " #{@blog.description} "
  end
  
  it "should make slug available" do
    output = Liquid::Template.parse( ' {{ blog.slug }} '  ).render('blog' => BlogDrop.new(@blog))
    output.should == " #{@blog.slug} "
  end
  
  it "should make blog image available" do
    @blog.image = File.new(RAILS_ROOT + '/spec/fixtures/test-jpg.jpg')
    output = Liquid::Template.parse( ' {{ blog.image_url }} '  ).render('blog' => BlogDrop.new(@blog))
    output.should == " #{@blog.image.url(:small)} "
  end
  
  describe "entries" do
    it "should return this blog's published entries ordered with the most recently published first" do
      entries = (1..3).collect { |n| Factory(:published_entry, :title => "Blog numba #{n}", :blog => @blog, :published_at => (5-n).days.ago) }
      
      output = Liquid::Template.parse( ' {% for entry in blog.entries %} {{ entry.title }} {% endfor %} '  ).render('blog' => BlogDrop.new(@blog))
      output.should == "  #{ entries.reverse.collect{ |e| e.title }.join('  ') }  "
    end
    
    describe "entry pagination" do
      before do
        @entries = (1..22).collect { |n| Factory(:published_entry, :title => "Blog numba #{n}", :blog => @blog, :published_at => n.days.ago) }
      end

      it "should return 20 entries on first page by default" do
        output = Liquid::Template.parse( ' {% for entry in blog.entries %} {{ entry.title }} {% endfor %} {{ blog.entries.total_entries }}'  ).render('blog' => BlogDrop.new(@blog))
        output.should == "  #{ @entries[0...20].collect{ |e| e.title }.join('  ') }  "
      end

      it "should return page 2" do
        output = Liquid::Template.parse( ' {% for entry in blog.entries %} {{ entry.title }} {% endfor %} '  ).render({'blog' => BlogDrop.new(@blog)}, :registers => { :page => 2 } )
        output.should == "  #{ @entries[20..21].collect{ |e| e.title }.join('  ') }  "
      end

      it "should return 10 entries per page" do
        output = Liquid::Template.parse( ' {% for entry in blog.entries %} {{ entry.title }} {% endfor %} '  ).render({'blog' => BlogDrop.new(@blog)}, :registers => { :per_page => 10 } )
        output.should == "  #{ @entries[0...10].collect{ |e| e.title }.join('  ') }  "
      end
    end
  end
end
