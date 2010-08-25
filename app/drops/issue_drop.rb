class IssueDrop < Drop
  alias_method :issue, :source # for readability

  liquid_attributes :id, :name, :date, :number, :volume, :description

  def url
    "/issues/#{issue.id}"
  end

  def articles
    issue.articles.published.find(:all, :order => "published_at desc").collect{ |article| ArticleDrop.new(article) }
  end
  
  def large_cover_image_url
    issue.pdf.url(:system_default)
  end
  
  def small_cover_image_url
    issue.pdf.url(:system_cover_thumb)
  end
  
  def screen_pdf_url
    issue.pdf.url(:screen_quality)
  end
  
  def press_pdf_url
    issue.pdf.url(:original)
  end
  
  def has_pdf?
    !!issue.pdf_file_name
  end
end
