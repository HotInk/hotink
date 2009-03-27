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
  accepts_nested_attributes_for :sortings, :allow_destroy => true     
  accepts_nested_attributes_for :authorships, :allow_destroy => true
  
  
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
  
  # Returns list of article's author names as a readable list, separated by commas and the word "and".
  def authors_list
     case self.authors.length
     when 0
       return false
     when 1
       return self.authors.first.name
     when 2
       return self.authors.first.name + " and " + self.authors.second.name
     else
      list = String.new
      (0..(self.authors.count - 3)).each{ |i| list += authors[i].name + ", " }
      list += authors[self.authors.length-2].name + " and " + authors[self.authors.length-1].name # last two authors get special formatting
      return list
    end         
  end
  
  #Breaks up a human readable list of authors and creates each one and adds it to self.authors.
  def authors_list=(list)
    if list
      list.split(/, and | and |,/).each do |name| 
        author = Author.find_or_create_by_name_and_account_id(name.strip, self.account.id)
        self.authors << author unless self.authors.member?(author) || author.nil?
      end
    end
  end
  
end
