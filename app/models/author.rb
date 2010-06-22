class Author < ActiveRecord::Base
  belongs_to :account

  has_many :authorships, :dependent => :destroy
  has_many :articles, :through => :authorships 
  
  has_many :photocredits, :dependent => :destroy
  has_many :mediafiles, :through => :photocredits
  
  validates_presence_of :account, :message => "must have an account"
  validates_associated :account, :message => "Account must be valid"
  validates_presence_of :name, :message => "must have a name"
  validates_uniqueness_of :name, :scope => :account_id
end
