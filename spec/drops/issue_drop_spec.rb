require 'spec_helper'

describe IssueDrop do
  before do
    @issue = Factory(:issue, :name => "Test issue", :number => "12", :volume => "15", :description => "Important stuff")
  end
  
  it "should make basic issue data available" do
    output = Liquid::Template.parse( ' {{ issue.id }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.id} "
    
    output = Liquid::Template.parse( ' {{ issue.number }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.number} "
    
    output = Liquid::Template.parse( ' {{ issue.volume }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.volume} "
    
    output = Liquid::Template.parse( ' {{ issue.name }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.name} "
    
    output = Liquid::Template.parse( ' {{ issue.description }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.description} "
  end

  it "should return a issue date" do
    output = Liquid::Template.parse( ' {{ issue.date | date:"%B %e %Y" }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " #{@issue.date.to_time.strftime("%B %e %Y")} "
  end
  
  it "should return issue url" do
    output = Liquid::Template.parse( ' {{ issue.url }} '  ).render('issue' => IssueDrop.new(@issue))
    output.should == " /issues/#{@issue.id} "
  end

  describe "articles" do
    it "should return this issues's published articles ordered with the most recently published first" do
      articles = (1..3).collect do |n| 
        article = Factory(:published_article, :title => "Article number #{n}", :published_at => (5-n).days.ago, :account => @issue.account )
        @issue.articles << article
        article
      end
      
      output = Liquid::Template.parse( ' {% for article in issue.articles %} {{ article.title }} {% endfor %} '  ).render('issue' => IssueDrop.new(@issue))
      output.should == "  #{ articles.reverse.collect{ |a| a.title }.join('  ') }  "
    end
  end
end