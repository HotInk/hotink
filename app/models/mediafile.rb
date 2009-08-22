# Mediafile is an easy class to extend. But, if you do, rememeber to add support in:
#  - _edit_media_form.html.erb
#  - appropriate partials in app/views/mediafiles/article_form and app/views/mediafiles/entry_form
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
      :path => ":rails_root/public/system/:account/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:account/:class/:id_partition/:basename_:style.:extension"
  
  define_index do
    indexes title, :sortable => :true
    indexes file_file_name, :as => :file_name
    indexes file_content_type, :as => :content_type, :sortable => :true
    indexes file_file_size, :as => :file_size, :sortable => :true
    indexes description
    indexes authors.name, :as => :credits
    indexes tags.name, :as => :tags
    indexes date, :sortable => :true

    has created_at
    has account_id
    has type
    
    set_property :delta => :delayed
  end
  
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
  
  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.mediafile do
       xml.tag!( :title, self.title )
       xml.tag!( :type, self.type || "File" )
       xml.tag!( :date, self.date )
       xml.tag!( :authors_list, self.authors_list )
       xml.tag!( :url, self.file.url )
       xml.tag!( :content_type, self.file_content_type )
       xml.tag!( :id, self.id )
     end
  end
  
end
