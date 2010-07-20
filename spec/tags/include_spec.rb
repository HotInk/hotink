require 'spec_helper'

describe Include do
  it "should find and include partial template" do
    partial = Factory(:partial_template, :name => "Test partial", :code => "This is a partial template")
    output = Liquid::Template.parse( " {% include \"#{partial.name}\" %} "  ).render({}, :registers => { :design => partial.design } )
    output.should == " #{partial.code} "
  end

  it "should include partial template variable, if supplied" do
    partial = Factory(:partial_template, :name => "Smart partial", :code => "{{ article.title }}")
    article = Factory(:article, :title => "Testing liquid partial tag")
    output = Liquid::Template.parse( " {% include \"#{partial.name}\" for article %} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => partial.design } )
    output.should == " #{article.title} "
  end
  
  it "should only include templates from from the current design" do
    partial = Factory(:partial_template, :name => "Smart partial", :code => "{{ article.title }}")
    other_design = Factory(:design)
    article = Factory(:article, :title => "Testing liquid partial tag")
    output = Liquid::Template.parse( " {% include \"#{partial.name}\" for article %} "  ).render({'article' => ArticleDrop.new(article)}, :registers => { :design => other_design } )
    output.should == " <!-- No partial named \"#{partial.name}\" found in this design --> "
  end
end
