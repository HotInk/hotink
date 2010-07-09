class Include < Liquid::Tag
  IncludeTagSyntax = /(#{Liquid::QuotedFragment}+)(\s+(?:with|for)\s+(#{Liquid::QuotedFragment}+))?/

  def initialize(tag_name, markup, tokens)      
    if markup =~ IncludeTagSyntax
      @template_name = $1        
      @variable_name = $3
      @attributes    = {}
    end

    super
  end

  def parse(tokens)      
  end

  def render(context)      
    design = context.registers[:design]
    partial = design.partial_templates.find_by_name(context[@template_name])     
    
    if partial
      variable = context[@variable_name || @template_name[1..-2]]

      context.stack do
        if variable.is_a?(Array)

          variable.collect do |variable|            
            context[@template_name[1..-2]] = variable
            partial.render(context)
          end

        else

          context[@template_name[1..-2]] = variable
          partial.render(context)
        end
      end
    else
      no_partial_found_template = Liquid::Template.parse("<!-- No partial named \"#{context[@template_name]}\" found in this design -->")
      no_partial_found_template.render(context)
    end
  end
end