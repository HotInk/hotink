module TemplateFileFilters
  
  def template_file_url(filename)
    design = @context.registers[:design]
    template_file = design.template_files.find_by_file_file_name(filename)
    if template_file
      template_file.url
    else
      "<!-- This design has no template file named \"#{filename}\" -->"
    end
  end
  
  def template_file_tag(filename)
    design = @context.registers[:design]

    template_file = design.template_files.find_by_file_file_name(filename)

    if template_file.nil?
      "<!-- No template file named:\"#{filename}\" -->"
    else
      case template_file.file_name.split('.')[-1]  
      when 'js', 'htc'
        "<script src=\"#{template_file.url}\" type=\"text/javascript\" charset=\"utf-8\"></script>"
      when 'png', 'jpg', 'gif', 'jpeg'
        "<img src=\"#{template_file.url}\" />"
      when 'css'
        "<link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"#{template_file.url}\" />"
      else
        "<a href=\"#{template_file.url}\" name=\"#{template_file.file_name}\">#{ template_file.file_name }</a>" 
      end
    end
  end
  
end