class Attachment < ActiveRecord::Base
  belongs_to :account
  
  has_many :waxings
  has_many :articles, :through => :waxings
  
  has_many :photocredits
  has_many :authors, :through => :photocredits
end
