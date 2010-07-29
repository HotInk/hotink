require 'spec_helper'

describe CommentDrop do
  before do
    @comment = Factory(:comment)
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
end
