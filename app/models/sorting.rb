class Sorting < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :category
  belongs_to :section, :foreign_key => :category_id, :class_name => "Section"
  
  belongs_to :document
  belongs_to :article, :foreign_key => :document_id, :class_name => "Article"
  
  after_create :mark_article_as_updated
  before_destroy :mark_article_as_updated
  
  private
  
  def mark_article_as_updated
    self.article.update_attributes(:updated_at => Time.now) if self.article
  end
  
  
end
