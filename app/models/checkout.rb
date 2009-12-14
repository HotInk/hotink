class Checkout < ActiveRecord::Base
  belongs_to :original_article, :class_name => "Article"
  belongs_to :duplicate_article, :class_name => "Article"
  
  validates_presence_of :original_article
  validates_presence_of :duplicate_article
end
