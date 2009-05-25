class Posting < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :blog
  belongs_to :entry
  
  validates_presence_of :blog, :entry
  validates_associated :blog, :entry

end
