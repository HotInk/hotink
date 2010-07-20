class PageDrop < Drop
  alias_method :page, :source # for readability
  
  liquid_attributes :name, :url
  
  def contents
    RDiscount.new(page.contents).to_html
  end
  
  def raw_contents
    page.contents
  end
end