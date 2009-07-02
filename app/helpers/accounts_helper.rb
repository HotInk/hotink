module AccountsHelper
  
  def geometry_string_height( geometry_string )
    if (geometry_string.split("x").length==2)
      return geometry_string.split(/x|>/).last
    else
      return ""
    end
  end
  
  def geometry_string_width ( geometry_string )
      return geometry_string.split(/x|>/).first  
  end
  
end
