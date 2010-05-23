module BlogsHelper
  
  def generate_slug(text)
    return unless text
    res = text.downcase.strip
    res.gsub!('\'', "") #apostrophes
    res.gsub!(/[\W]+/, '-') #non-word characters
    res.gsub!(/^-+|-+$/, "") #leading/trailing dashes
    res
  end
end
