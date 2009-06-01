class Category < ActiveRecord::Base
  belongs_to :account
  
  has_many :sortings, :dependent => :destroy
  has_many :articles, :through => :sortings
  
  belongs_to :parent, :class_name => "Category"
  has_many :children, :class_name => "Category", :foreign_key=>:parent_id, :order => "position"
  
  acts_as_list
    
  def scope_condition
      "account_id = #{account_id} AND parent_id = #{(parent_id.nil? ? "NULL" : parent_id)}"
  end
  
  #Callbacks
  before_destroy :orphan_child_categories  
  
  def has_children?
    self.children.blank? ? false : true
  end
  
  #Be sure to remove references to self in child categories before destroy
  def orphan_child_categories
    self.children.each do |child|
      child.parent_id = nil
      child.save
    end
  end
  
end
