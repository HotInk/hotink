class Author < ActiveRecord::Base
  belongs_to :account

  has_many :authorships
  has_many :articles, :through => :authorships 
  
  has_many :photocredits
  has_many :attachments, :through => :photocredits
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
  validates_presence_of :name, :message => "Author must have a name"
end
