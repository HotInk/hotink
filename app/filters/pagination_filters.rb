module PaginationFilters
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 20

  def next_page_link(text="Next &raquo;")
   page = (@context.registers[:page] || DEFAULT_PAGE).to_i
   per_page = (@context.registers[:per_page] || DEFAULT_PER_PAGE).to_i
   total_entries = (@context.registers[:total_entries] || 0).to_i

   build_link_tag next_page_params(page, per_page, total_entries), text
  end
  
  def previous_page_link(text="&laquo; Previous")
    page = (@context.registers[:page] || DEFAULT_PAGE).to_i
    per_page = (@context.registers[:per_page] || DEFAULT_PER_PAGE).to_i
    total_entries = (@context.registers[:total_entries] || 0).to_i
    

    build_link_tag previous_page_params(page, per_page, total_entries), text
  end
  
  private 
  
  def build_link_tag(params, text)
    title = text
    query_string = params.dup
    
    add_param(query_string, :design_id, @context.registers[:design].id) unless @context.registers[:design].current_design?
  
    if params.blank?
      ""
    else
      "<a href=\"?#{query_string}\">#{title}</a>" 
    end
  end
    
  def next_page_params(page, per_page, total_entries)
    if total_entries<=per_page || (page*per_page)>=total_entries
      ""
    else
      params = ""
      add_param params, :page, page + 1
      add_param params, :per_page, per_page unless per_page==DEFAULT_PER_PAGE
      params
    end
  end
  
  def previous_page_params(page, per_page, total_entries)
    if page==1
      ""
    else
      params = ""
      add_param params, :page, page - 1
      add_param params, :per_page, per_page unless per_page==DEFAULT_PER_PAGE
      params
    end
  end
  
  def add_param(query_string, param_name, param_value)
    query_string << "&" unless query_string.blank?
    query_string << "#{param_name.to_s}=#{param_value.to_s}"
  end
end
