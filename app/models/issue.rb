class Issue < ActiveRecord::Base
  belongs_to :account
  
  has_many :printings
  has_many :articles, :through => :printings
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
  validates_presence_of :date, :message => "Must have a date"
end
