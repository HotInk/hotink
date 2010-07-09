require 'spec_helper'

describe PageDrop do
  before do
    @page = Factory(:page, :name => "about", :contents => "this is a **real** page.")
  end
  
  it "should make page name available" do
    output = Liquid::Template.parse( ' {{ page.name }} '  ).render('page' => PageDrop.new(@page))
    output.should == " about "
  end
  
  it "should make Markdown rendered contents available" do
    output = Liquid::Template.parse( ' {{ page.contents }} '  ).render('page' => PageDrop.new(@page))
    output.should == " <p>this is a <strong>real</strong> page.</p>\n "
  end
  
  it "should make raw contents available" do
    output = Liquid::Template.parse( ' {{ page.raw_contents }} '  ).render('page' => PageDrop.new(@page))
    output.should == " this is a **real** page. "
  end
  
  it "should make url available" do
    output = Liquid::Template.parse( ' {{ page.url }} '  ).render('page' => PageDrop.new(@page))
    output.should == " #{@page.url} "
  end
end
