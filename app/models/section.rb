class Section < Category
  belongs_to :account
  #Here we override parent realationship from superclass "Category"
  #Sections have parents that are other sections, not other categories
  belongs_to :parent, :class_name => "Section"
  
  has_many :sortings
  has_many :articles, :through => :sortings

  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
  validates_presence_of :name, :message => "Section must have a name"
  validates_uniqueness_of :name, :scope => :account_id, :message => "Section name must be unique"
end
