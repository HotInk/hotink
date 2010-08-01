require 'spec_helper'

describe CategoriesHelper do
  include CategoriesHelper
  
  it "should return a list of parent category options, organized in a tree" do
    categories = (1..2).collect{ Factory(:category, :children => [Factory(:category, :children => (1..2).collect{ Factory(:category) })]) }
    
    expected_options = "<option value=\"\">None</option><option value=\"#{categories.first.id}\">#{categories.first.name}</option>#{indent_child_options_for_category_select(categories.first)}" 
    expected_options += "<option value=\"#{categories.second.id}\">#{categories.second.name}</option>#{indent_child_options_for_category_select(categories.second) }" 
    
    options_for_parent_category_select(categories).should == expected_options
  end

  it "should return a list of parent category options, with varous default messages" do
    options_for_parent_category_select([], :parent).should == "<option value=>Parent category</option>"
    options_for_parent_category_select([], :none).should == ""
  end
  
  it "should return a list of category options, organized in a tree" do
    categories = (1..2).collect{ Factory(:category, :children => [Factory(:category, :children => (1..2).collect{ Factory(:category) })]) }
    
    expected_options = "<option value=\"\">None</option><option value=\"#{categories.first.id}\">#{categories.first.name}</option>#{indent_child_options_for_category_select(categories.first)}" 
    expected_options += "<option value=\"#{categories.second.id}\">#{categories.second.name}</option>#{indent_child_options_for_category_select(categories.second) }" 
    
    options_for_category_select(categories).should == expected_options
  end
  
  it "should return a blank list of category options, if appropriate" do
    options_for_category_select([]).should == %{<option value="">None</option>}
  end
  
  it "should return an indented list of child categories" do
    category = Factory(:category, :children => [Factory(:category, :children => (1..2).collect{ Factory(:category) })])
    
    expected_options = "<option value=\"#{category.children.first.id}\">-#{category.children.first.name}</option>"
    category.children.first.children.each { |c| expected_options += "<option value=\"#{c.id}\">--#{c.name}</option>" }
    
    indent_child_options_for_category_select(category, nil, "-").should == expected_options
  end
  
  it "should properly mark selected category in an indented list of child categories" do
    selected_category = Factory(:category)
    category = Factory(:category, :children => [selected_category] )
    indent_child_options_for_category_select(category, selected_category, "-").should == "<option selected=\"selected\" value=\"#{selected_category.id}\">-#{selected_category.name}</option>"
  end
end
