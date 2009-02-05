class Issue < ActiveRecord::Base
  belongs_to :account
  
  has_many :printings
  has_many :articles, :through => :printings
end
