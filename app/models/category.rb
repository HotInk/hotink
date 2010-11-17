class Category < ActiveRecord::Base
  belongs_to :account
  
  has_many :sortings, :dependent => :destroy
  has_many :articles, :through => :sortings, :uniq => true
  
  belongs_to :parent, :class_name => "Category", :foreign_key=>:parent_id
  has_many :children, :class_name => "Category", :foreign_key=>:parent_id, :order => "position"
  has_many :subcategories, :class_name => "Category", :foreign_key=>:parent_id, :order => "position"  
  
  validates_presence_of :account, :message => "must have an account"
  validates_presence_of :name
  
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }
  
  named_scope :sections, :conditions => { :parent_id => nil }
  named_scope :main_categories, :conditions => { :parent_id => nil }
  
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
  
  def to_json
    Yajl::Encoder.encode to_hash
  end
  
  def to_hash
     { :id => id,
       :name => name,
       :slug => slug,
       :type => "Category",
       :subcategories => subcategories.collect { |s| s.to_hash } }
  end

  # Slug
  attr_protected :slug
  validates_uniqueness_of :slug, :scope => [:account_id, :parent_id], :if => :active
  validates_format_of :slug, :with => /^[-a-z0-9êçèé]+$/, :message => "should consist of letters, numbers and dashes only"
  before_validation :autoset_slug

  def path
    "#{parent_path}/#{slug.downcase}"
  end
    
  def parent_path
    if parent
      parent.path
    else
      ""
    end
  end
  
  # Find category using a path of parent-child category slugs (ie. "category-1/category2") 
  # or an array of page names (ie ["category1", "category2"])
  def self.find_by_path(path)
    if path.is_a? Array
      category_slugs = path
    elsif path.is_a? String
      category_slugs = path.split("/")
    end
    category = self.main_categories.find_by_slug(category_slugs.delete_at(0))
    raise ActiveRecord::RecordNotFound unless category
    unless category_slugs.blank?
      category_slugs.each do |category_slug|
        category = category.subcategories.find_by_slug(category_slug)
        raise ActiveRecord::RecordNotFound unless category
      end
    end
    category
  end
  
  private
  
  def autoset_slug
    self.slug = generate_slug(self.name) if self.slug.blank?
  end
  
  def generate_slug(text)
    return unless text
    slug = text.downcase.strip
    slug.gsub!('\'', "") #apostrophes, etc
    slug.gsub!('&', "and") #ampersands, etc
    slug.gsub!(/[\W]+/, '-') #non-word characters
    slug.gsub!(/^-+|-+$/, "") #leading/trailing dashes
    slug
  end
  
end
