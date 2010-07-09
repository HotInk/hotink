require 'spec_helper'

describe ListDrop do
  before do
    @list = Factory(:list)
  end
  
  it "should make basic list data available" do
    output = Liquid::Template.parse( ' {{ list.id }} '  ).render('list' => ListDrop.new(@list))
    output.should == " #{@list.id} "

    output = Liquid::Template.parse( ' {{ list.name }} '  ).render('list' => ListDrop.new(@list))
    output.should == " #{@list.name} "
    
    output = Liquid::Template.parse( ' {{ list.slug }} '  ).render('list' => ListDrop.new(@list))
    output.should == " #{@list.slug} "
    
    output = Liquid::Template.parse( ' {{ list.description }} '  ).render('list' => ListDrop.new(@list))
    output.should == " #{@list.description} "
  end
  
  it "should make list articles available" do
    articles = (1..4).collect{ |n| Factory(:published_article, :title => "Title ##{n}") }
    @list.documents = articles
    
    output = Liquid::Template.parse( ' {% for article in list.articles %} {{ article.title }} {% endfor %} '  ).render('list' => ListDrop.new(@list))
    output.should == "  #{ articles.collect{ |a| a.title }.join('  ') }  "
  end
  
  it "should not make scheduled or unpublished articles available" do
    draft_articles = (1..2).collect{ |n| Factory(:article, :title => "Do show me! I'M STILL UNFINISHED ##{n}") }
    scheduled_articles = (1..2).collect{ |n| Factory(:scheduled_article, :title => "Don't show me, I'm scheduled! ##{n}") }
    articles = (1..4).collect{ |n| Factory(:published_article, :title => "Title ##{n}") }
    @list.documents = articles + scheduled_articles + draft_articles
    
    output = Liquid::Template.parse( ' {% for article in list.articles %} {{ article.title }} {% endfor %} '  ).render('list' => ListDrop.new(@list))
    output.should == "  #{ articles.collect{ |a| a.title }.join('  ') }  "
  end
end
