class Attachment < ActiveRecord::Base
  belongs_to :account
  
  has_many :waxings
  has_many :articles, :through => :waxings
  
  has_many :photocredits
  has_many :authors, :through => :photocredits
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
end
