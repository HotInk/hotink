module CategoriesHelper
  
  #Build options for parent category selection while honoring parent/child relationships in formatting.
  def options_for_category_select(collection={}, category = Category.new)
    type = category.is_a?(Section) ? "section" : "category"
    html_code = "<option value="">Parent #{type}</option>"
    if collection.empty?
      html_code
    else
      parents = collection.select{ |kategory| kategory.parent_id.nil? }
      parents.each do |parent|
        options = {:value => parent.id}
        options = options.merge({:selected=>"selected"}) if parent == category.parent
        html_code += tag("option", options, true) + parent.name + "</option>" + indent_and_display_child_options(category, parent) unless parent==category
      end
      html_code
    end

  end
  
  private
  
  #Recursive function for displaying select tag options for categories while preserving the relationship visually.
  #This function is sure not to display the category currently under consideration, as one category
  #cannot be its own child or parent.
  def indent_and_display_child_options(category, parent, child_indent = "&nbsp;&nbsp;&nbsp;")
    html_code = ""
    parent.children.each do |child|
      options = {:value => child.id}
      options = options.merge({:selected=>"selected"}) if child == category.parent
      html_code += tag("option", options, true) + child_indent + child.name + "</option>" + indent_and_display_child_options(category, child, child_indent + child_indent) unless child==category
    end
    html_code
  end
  
  
end
