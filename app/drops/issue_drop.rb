class IssueDrop < Drop
  alias_method :issue, :source # for readability

  liquid_attributes :id, :date, :number, :volume, :description

  def articles
    issue.articles.published.find(:all, :order => "published_at desc").collect{ |article| ArticleDrop.new(article) }
  end
end
