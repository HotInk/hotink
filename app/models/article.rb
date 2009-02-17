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
  has_many :attachments, :through => :waxings
  
  acts_as_taggable_on :tags
  
  accepts_nested_attributes_for :sortings, :allow_destroy => true
  
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



  
  def display_title
    if self.title and self.title.strip != ""
      return self.title
    else 
      return "(no headline)"
    end
  end
  
  def new_authors_list
    return ""
  end
  
end
