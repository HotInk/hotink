class Category < ActiveRecord::Base
  belongs_to :account
  
  has_many :sortings
  has_many :articles, :through => :sortings
  
  belongs_to :parent, :class_name => "Category"
  has_many :children, :class_name => "Category", :foreign_key=>:parent_id
  
  acts_as_list :scope=>:account
  
  #Callbacks
  before_destroy :orphan_child_categories  
  
  #Be sure to remove references to self in child categories before destroy
  def orphan_child_categories
    self.children.each do |child|
      child.parent_id = nil
      child.save
    end
  end
  
end
