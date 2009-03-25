class Article < ActiveRecord::Base
  belongs_to :account
  
  has_many :authorships
  has_many :authors, :through => :authorships
  
  has_many :printings
  has_many :issues, :through => :printings
  
  belongs_to :section
  has_many :sortings
  has_many :categories, :through => :sortings
  
  has_many :waxings
  has_many :mediafiles, :through => :waxings
  has_many :images, :through => :waxings, :source=>'mediafile'
  
  acts_as_taggable_on :tags
  
  accepts_nested_attributes_for :mediafiles
  accepts_nested_attributes_for :sortings, :allow_destroy => true     #, :reject_if => proc { |attributes| attributes['category_id'].blank? && attributes['_delete'].blank? }
  accepts_nested_attributes_for :authorships, :allow_destroy => true #, :reject_if => proc { |attributes| attributes['author_id'].blank? && attributes['_delete'].blank? }
  
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"


  define_index do
    indexes title, :sortable => :true
    indexes subtitle
    indexes bodytext
    indexes date, :sortable => :true

    has created_at
    has account_id
  end

  def self.per_page
      10
  end

  
  def display_title
    if self.title and self.title.strip != ""
      return self.title
    else 
      return "(no headline)"
    end
  end
  
  def authors_list
     
  end
  
  def authors_list=(list)
    if list
      list.split(/, and | and |,/).each{ |name| self.authors.create(:name=>name, :account_id=>self.account.id) }
    end
  end
  
end
