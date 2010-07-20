class ListItem < ActiveRecord::Base
  belongs_to :list
  validates_presence_of :list
  
  belongs_to :document
  validates_presence_of :document
end
