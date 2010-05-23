module CategoriesHelper
  
  #Build options for parent category selection while honoring parent/child relationships in formatting.
  def options_for_parent_category_select(collection={}, blank_message = :default, category = Category.new)
    
    case blank_message
      when :parent
        type = category.is_a?(Section) ? "section" : "category"
        html_code = "<option value="">Parent #{type}</option>"
      when :default
        html_code = "<option value="">None</option>"
      when :none
        html_code = ""
      end
            
    if collection.empty?
      html_code
    else
      parents = collection.select{ |kategory| kategory.parent_id.nil? }
      parents.each do |parent|
        options = {:value => parent.id}
        options = options.merge({:selected=>"selected"}) if parent == category.parent
        html_code += tag("option", options, true) + parent.name + "</option>" + indent_child_options_for_parent_category_select(category, parent) unless parent==category
      end
      html_code
    end

  end
  
  # Build options for category selection while honoring parent/child relationships in formatting.
  # If you're looking to create select options for a parent category, you should use
  # options_for_parent_category_select instead.
  def options_for_category_select(collection={}, category = Category.new)
    
    html_code = "<option value="">None</option>"
      
    if collection.empty?
      html_code
    else
      parents = collection.select{ |kategory| kategory.parent_id.nil? }
      parents.each do |parent|
        options = {:value => parent.id}
        options = options.merge({:selected=>"selected"}) if parent == category
        html_code += tag("option", options, true) + parent.name + "</option>" + indent_child_options_for_category_select(parent, category)
      end
      html_code
    end

  end
    
  #Recursive function for displaying select tag options for categories while preserving the relationship visually.
  #This function is sure not to display the category currently under consideration, as one category
  #cannot be its own child or parent.
  def indent_child_options_for_parent_category_select(category, parent, child_indent = "&nbsp;&nbsp;&nbsp;")
    html_code = ""
    parent.children.each do |child|
      options = {:value => child.id}
      options = options.merge({:selected=>"selected"}) if child == category.parent
      html_code += tag("option", options, true) + child_indent + child.name + "</option>" + indent_child_options_for_parent_category_select(category, child, child_indent + child_indent) unless child==category
    end
    html_code
  end
  
  #Recursive function for displaying select tag options for subcategories while preserving their parent/child relationship visually.
  def indent_child_options_for_category_select(parent, category=nil, child_indent = "&nbsp;&nbsp;&nbsp;")
    html_code = ""
    parent.children.each do |child|
      options = {:value => child.id}
      options = options.merge({:selected=>"selected"}) if child == category
      html_code += tag("option", options, true) + child_indent + child.name + "</option>" + indent_child_options_for_category_select(child, category, child_indent + child_indent)
    end
    html_code
  end
  
  
end
