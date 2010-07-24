class Checkout < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  
  belongs_to :user
  belongs_to :original_article, :class_name => "Article", :foreign_key => "original_article_id"
  belongs_to :duplicate_article, :class_name => "Article", :foreign_key => "duplicate_article_id"
  
  validates_presence_of :original_article
  validates_presence_of :duplicate_article
end
