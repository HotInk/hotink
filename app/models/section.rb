class Section < Category
  belongs_to :account
  #Here we override parent realationship from superclass "Category"
  #Sections have parents that are other sections, not other categories
  belongs_to :parent, :class_name => "Section"
  
  has_many :sortings
  has_many :articles, :through => :sortings
end
