class Category < ActiveRecord::Base
  belongs_to :account
  
  has_many :sortings, :dependent => :destroy
  has_many :articles, :through => :sortings
  
  belongs_to :parent, :class_name => "Category", :foreign_key=>:parent_id
  has_many :children, :class_name => "Category", :foreign_key=>:parent_id, :order => "position"
  has_many :subcategories, :class_name => "Category", :foreign_key=>:parent_id, :order => "position"  
  
  validates_presence_of :account, :message => "must have an account"
  validates_presence_of :name
  
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }
  
  named_scope :sections, :conditions => { :parent_id => nil }
  
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

  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.section do
       xml.tag!( :position, self.position )
       xml.tag!( :id, self.id )
       xml.tag!( :name, self.name)
       xml.tag!( :parent_id, self.parent.blank? ? "" : self.parent.id )
       xml.children :type => "array" do
         self.children.each do |category|
           xml.<< category.to_xml(:skip_instruct => true)
         end
       end
     end
  end

  
end
