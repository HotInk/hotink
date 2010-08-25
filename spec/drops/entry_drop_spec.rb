require 'spec_helper'

describe EntryDrop do
  before do
    @entry = Factory(:entry, :blog => Factory(:blog, :title => "Test title"))
  end

  it "should return the entry's blog in a blog drop" do
    output = Liquid::Template.parse( ' {{ entry.blog.title }} '  ).render('entry' => EntryDrop.new(@entry))
    output.should == " #{@entry.blog.title} "
  end
  
  it "should return the entry's url" do
    output = Liquid::Template.parse( ' {{ entry.url }} '  ).render('entry' => EntryDrop.new(@entry))
    output.should == " /blogs/#{@entry.blog.slug}/#{@entry.id} "
  end
end
