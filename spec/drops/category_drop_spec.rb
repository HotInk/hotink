require 'spec_helper'

describe CategoryDrop do
  before do
    @category = Factory(:category)
  end
  
  it "should return the category's url" do
    output = Liquid::Template.parse( ' {{ category.url }} '  ).render('category' => CategoryDrop.new(@category))
    output.should == " /categories#{@category.path} "
  end
  
  it "should make name available" do
    output = Liquid::Template.parse( ' {{ category.name }} '  ).render('category' => CategoryDrop.new(@category))
    output.should == " #{@category.name } "
  end
  
  it "should make slug available" do
    output = Liquid::Template.parse( ' {{ category.slug }} '  ).render('category' => CategoryDrop.new(@category))
    output.should == " #{@category.slug } "
  end
  
  it "should make path available" do
    output = Liquid::Template.parse( ' {{ category.path }} '  ).render('category' => CategoryDrop.new(@category))
    output.should == " #{@category.path } "
  end
  
  describe "subcategories" do
    before do
      @child1 = Factory(:category)
      @child2 = Factory(:category)
      @category.children = [@child1,@child2]
    end
    
    it "should return child categories as 'subcategories'" do
      output = Liquid::Template.parse( ' {% for subcategory in category.subcategories %} {{ subcategory.name }} {% endfor %} '  ).render('category' => CategoryDrop.new(@category))
      output.should == "  #{ @category.children.collect{ |c| c.name }.join('  ') }  "
    end
    
    it "should return specific child category by name" do
      output = Liquid::Template.parse(" {{ category.subcategory[\"#{@child1.name}\"].name }} ").render('category' => CategoryDrop.new(@category))
      output.should == " #{ @child1.name } "
    end
  end
  
  describe "articles" do
    it "should know whether the category has any attached articles" do
      category = Factory(:category)
      category_with_some_articles = Factory(:category, :articles => (1..3).collect{ Factory(:published_article) } )
      
      template = Liquid::Template.parse( ' {% if category.has_articles? %} YES {% else %} NO {% endif %} ')

      output = template.render('category' => CategoryDrop.new(category))
      output.should eql("  NO  ")

      output = template.render('category' => CategoryDrop.new(category_with_some_articles))
      output.should eql("  YES  ")
    end
  
    it "should return the categories articles" do
      @articles = (1..4).collect{ |n| Factory(:published_article, :title => "Article #{n}", :published_at => n.days.ago, :categories => [@category]) }
    
      output = Liquid::Template.parse( ' {% for article in category.articles %} {{ article.title }} {% endfor %} '  ).render('category' => CategoryDrop.new(@category))
      output.should == "  #{ @articles.collect{ |a| a.title }.join('  ') }  "
    end
  end
end
