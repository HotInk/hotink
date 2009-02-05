class Article < ActiveRecord::Base
  belongs_to :account
  
  has_many :authorships
  has_many :authors, :through => :authorships
  
  has_many :printings
  has_many :issues, :through => :printings
  
  has_many :sortings
  has_many :categories, :through => :sortings
  has_many :sections, :through => :sortings, :source => :category
  
  has_many :waxings
  has_many :attachments, :through => :waxings
  
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings
end
