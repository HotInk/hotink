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
  
end