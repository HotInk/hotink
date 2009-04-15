# Mediafile is an easy class to extend. But, if you do, rememeber to add support in:
#  - _edit_media_form.html.erb
#  - appropriate partial in app/views/mediafiles
#  - appropriate display selector in _article_mediafiles.html.erb
#  - appropriate create selector in mediafiles_controller.rb
# 
# If support inserted in those for places, in addition to a new model file, it should
# work just fine.

class Mediafile < ActiveRecord::Base
  belongs_to :account
  
  has_many :waxings, :dependent => :destroy
  has_many :articles, :through => :waxings
  
  has_many :photocredits
  has_many :authors, :through => :photocredits
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
  
  accepts_nested_attributes_for :photocredits, :allow_destroy => true
  
  acts_as_taggable_on :tags
  
  has_attached_file :file,
      :path => ":rails_root/public/system/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:class/:id_partition/:basename_:style.:extension"
  
  def title
    title = self.read_attribute(:title)
    if title and title.strip != ""
      return title.strip
    elsif filename = self.read_attribute(:file_file_name)
      return filename
    else
      return "No file"
    end
  end
      
  # Returns list of article's author names as a readable list, separated by commas and the word "and".
  def authors_list
     case self.authors.length
     when 0
       return nil
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
