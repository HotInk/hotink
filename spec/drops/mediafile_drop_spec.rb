require 'spec_helper'

describe MediafileDrop do
  before do
    @mediafile = Factory(:mediafile)
  end
  
  it "should make basic attributes available" do
    output = Liquid::Template.parse( ' {{ mediafile.url }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.url} "
  end
  
  describe "caption" do
    it "should make basic caption available if supplied" do
      output = Liquid::Template.parse( ' {{ mediafile.caption }} '  ).render('mediafile' => MediafileDrop.new(@mediafile, :caption => "Test caption"))
      output.should == " Test caption "
    end
    
    it "should display blank caption cleanly" do
      output = Liquid::Template.parse( ' {{ mediafile.caption }} '  ).render('mediafile' => MediafileDrop.new(@mediafile, :caption => nil))
      output.should == "  "
    end
  end
  
end
