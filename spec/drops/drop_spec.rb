require 'spec_helper'

describe Drop do
  before do
    @article = Factory(:published_article, :title => "Title", :subtitle => "Subtitle", :bodytext => "this is the **real** thing.")
  end
  
  it "should return a sane error message for non-existant methods" do
    output = Liquid::Template.parse( ' {{ article.no_way_this_exists }} '  ).render('article' => ArticleDrop.new(@article))
    output.should == " <span class=\"liquid_error\">No data named 'no_way_this_exists' in ArticleDrop</span> "
  end
end
