class Author < ActiveRecord::Base
  belongs_to :account

  has_many :authorships
  has_many :articles, :through => :authorships 
  
  has_many :photocredits
  has_many :attachments, :through => :photocredits
end
