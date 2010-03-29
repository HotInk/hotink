module BlogsHelper
  
  def generate_slug(text)
    return unless text
    res = text
    res = res.downcase
    res = res.strip
    res = res.gsub('\'', "")
    res = res.gsub(/[\W]+/, '-')
    res = res.gsub(/-+$/, "")
    res = res.gsub(/^-+/, "")\
  end
end
