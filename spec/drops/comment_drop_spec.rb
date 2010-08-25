require 'spec_helper'

describe CommentDrop do
  before do
    @comment = Factory(:comment)
  end
  
  describe "url" do
    it "should return url for article comment" do
      @comment.document = Factory(:published_article)
      
      output = Liquid::Template.parse( ' {{ comment.url }} '  ).render('comment' => CommentDrop.new(@comment))
      output.should == " /articles/#{@comment.document.id}#comment-#{@comment.id} "
    end
    
    it "should return url for blog entry comment" do
      @comment.document = Factory(:published_entry)
      
      output = Liquid::Template.parse( ' {{ comment.url }} '  ).render('comment' => CommentDrop.new(@comment))
      output.should == " /blogs/#{@comment.document.blog.slug}/#{@comment.document.id}#comment-#{@comment.id} "
    end
  end
    
  it "should make basic data available" do
    output = Liquid::Template.parse( ' {{ comment.name }} '  ).render('comment' => CommentDrop.new(@comment))
    output.should == " #{@comment.name} "
    
    output = Liquid::Template.parse( ' {{ comment.email }} '  ).render('comment' => CommentDrop.new(@comment))
    output.should == " #{@comment.email} "
    
    output = Liquid::Template.parse( ' {{ comment.ip_address }} '  ).render('comment' => CommentDrop.new(@comment))
    output.should == " #{@comment.ip_address} "
    
    output = Liquid::Template.parse( ' {{ comment.body }} '  ).render('comment' => CommentDrop.new(@comment))
    output.should == " #{@comment.body} "
  end
  
  it "should make date available" do
    output = Liquid::Template.parse( ' {{ comment.date | date: "%b %e, %G at %l:%M %P" }} '  ).render('comment' => CommentDrop.new(@comment))
    output.should == " #{@comment.created_at.to_datetime.strftime("%b %e, %G at %l:%M %P")} "
  end
  
end
