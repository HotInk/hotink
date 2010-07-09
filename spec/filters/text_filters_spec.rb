require 'spec_helper'

describe TextFilters do

   describe "markdown" do
     it "should return HTML interpretation of Markdown text" do
       markdown_text = "Here's *emphasis*, here's **strong**, here are <some entities> "
       output = Liquid::Template.parse( " {{ \"#{markdown_text}\" | markdown }} "  ).render({}, :filters => [TextFilters])
       output.should == " <p>Here's <em>emphasis</em>, here's <strong>strong</strong>, here are <some entities></p>\n "
     end
   end
   
   describe "shorten" do
     before do
       @long_text = "This is a sample to test the shorten filter. <em>Shortening is tougher than you think; you must worry about open tags</em>"
     end
     
     it "should shorten a long string to a certain number of words" do  
       output = Liquid::Template.parse( " {{ \"#{@long_text}\" | shorten: 5 }} "  ).render({}, :filters => [TextFilters])
       output.should == " This is a sample to… "
     end
     
     it "should close open HTML tags created by the shortening" do
       output = Liquid::Template.parse( " {{ \"#{@long_text}\" | shorten: 12 }} "  ).render({}, :filters => [TextFilters])
       output.should == " This is a sample to test the shorten filter. <em>Shortening is tougher</em>… "
     end
     
     it "should not change a short string" do
       output = Liquid::Template.parse( " {{ \"Too short too change\" | shorten: 12 }} "  ).render({}, :filters => [TextFilters])
       output.should == " Too short too change "
     end
     
     it "should only remove newline characters from start and end of string" do
       test_string_with_whitespace = <<-TESTSTRING
Leave

newlines
and whitespace
alone
when shortening 
and shortening
and shortening
and shortening
and shortening
and shortening
and shortening
and shortening
TESTSTRING
       output = Liquid::Template.parse( " {{ test_string | shorten: 12 }} "  ).render({'test_string' => test_string_with_whitespace}, :filters => [TextFilters])
       output.should == " #{test_string_with_whitespace.strip} "
     end
   end
end
