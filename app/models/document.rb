class Document < ActiveRecord::Base
  include Pacecar
  
  belongs_to :account
  
  has_many :authorships, :dependent => :destroy
  has_many :authors, :through => :authorships
  
  has_many :printings, :dependent => :destroy
  has_many :issues, :through => :printings
  
  belongs_to :section, :class_name => "Category", :foreign_key => 'section_id'
  has_many :sortings, :dependent => :destroy
  has_many :categories, :through => :sortings
  
  has_many :waxings, :dependent => :destroy
  has_many :mediafiles, :through => :waxings
  has_many :images, :through => :waxings, :source=>'mediafile', :conditions => { :type => 'Image'}
  
  def waxing_for(mediafile)
    waxings.find_by_mediafile_id(mediafile.id)
  end
  
  def caption_for(mediafile)
    waxing = waxing_for(mediafile)
    waxing.nil? ? nil : waxing.caption
  end
  
  named_scope :by_date_published, :order => "published_at DESC"
  
  # Publication statuses
  attr_protected :status
  
  named_scope :drafts, :conditions => "status is null"
  named_scope :scheduled, lambda { {:conditions => ["status = 'Published' AND published_at > ?", Time.now.utc]} }
  named_scope :published, lambda { {:conditions => ["status = 'Published' AND published_at <= ?", Time.now.utc]} }
  named_scope :published_or_scheduled, :conditions => {:status => 'Published'}, :order => 'published_at desc'   
  
  def published?
    (self.status=='Published') && (self.published_at <= Time.now)
  end
  
  def draft?
    self.status.nil? && self.published_at.nil?
  end
  
  def scheduled?
    (self.status=='Published') && (self.published_at > Time.now)
  end
  
  def untouched?
     self.updated_at == self.created_at
  end
  
  acts_as_taggable_on :tags
  acts_as_authorizable
  
  accepts_nested_attributes_for :mediafiles
  accepts_nested_attributes_for :sortings, :allow_destroy => true     
  accepts_nested_attributes_for :authorships, :allow_destroy => true
  
  validates_presence_of :account, :message => "must have an account"
  validates_associated :account, :message => "Account must be valid"

  define_index do
    indexes title, :sortable => :true
    indexes subtitle
    indexes bodytext
    indexes authors.name, :as => :authors_names
    indexes waxings.caption, :as => :captions
    indexes tags.name, :as => :tags
    indexes published_at, :sortable => :true

    has created_at
    has account_id
    has blog_id
    has type

    where "status = 'published'"
    
    set_property :delta => :delayed
  end

  def self.per_page
      10
  end
  
  def title
    title = read_attribute :title
    if title and title.strip != ""
      return title
    else 
      return "(no headline)"
    end
  end
  
  # Methods for managing document publication status 
  def publish(time_to_publish = nil)
    self.status = "Published"
    self.published_at = time_to_publish.kind_of?(Time) ? time_to_publish : Time.now
  end
  
  def publish!(time_to_publish = nil)
    publish(time_to_publish)
    save
  end
  
  def schedule(date)
    self.status = "Published"
    self.published_at = date
  end
  
  def schedule!(date)
    schedule(date)
    save
  end
  
  def unpublish
    self.status = nil
    self.published_at = nil
  end
  
  def unpublish!
    unpublish
    save
  end
  
  def date
    if published?||scheduled?
      published_at
    else
      updated_at
    end
  end
  
  # Categories are set in a checkbox style, and that's reflected in this attribute method.
  # 
  # Category attributes should be passed in as a hash with the category id as the key and 
  # a value of 0, "0", or anything ".blank?" to indicate no Sorting for this category and anything else to
  # indicate that a Sorting should exist 
  def categories_attributes=(attributes)
    raise ActiveRecord::AttributeAssignmentError unless attributes.is_a? Hash
    self.categories.clear
    attributes.each do | cat_id, value |
      unless value.blank? || value==0 || value=="0"
        if cat = account.categories.find(cat_id)
          categories << cat
        end
      end
    end
  end
  
  # Returns list of article's author names as a readable list, separated by commas and the word "and".
  def authors_list
     case self.authors.length
     when 0
       return nil
     when 1
       return self.authors.first.blank? ? "" : self.authors.first.name
     when 2
      #Catch cases where the second author is actually an editorial title, this is weirdly common.
      if self.authors.second.name =~ / editor| Editor| writer| Writer|Columnist/
        return self.authors.first.name + " - " + self.authors.second.name
      else
        return self.authors.first.name + " and " + self.authors.second.name
      end
     else
      list = String.new
      (0..(self.authors.length - 3)).each{ |i| list += authors[i].name + ", " }
      list += authors[self.authors.length-2].name + " and " + authors[self.authors.length-1].name # last two authors get special formatting
      return list
    end         
  end

  def authors_json
    authors.collect{ |a| { "id" => a.id, "name" => a.name } }.to_json
  end

  def word_count
    bodytext.nil? ? 0 : bodytext.scan(/\w+/).size
  end
  
  #Breaks up a human readable list of authors and creates each one and adds it to self.authors.
  def authors_list=(list)
    if list
      list.split(/,|, and | and /).each do |name| 
        author = Author.find_or_create_by_name_and_account_id(name.strip, self.account.id)
        self.authors << author unless self.authors.member?(author) || author.nil?
      end
    end
  end
  
  def owner
    has_owners.blank? ? nil : has_owners.first
  end
  
  def owner=(user)
    has_owners.each do |owner|
      owner.has_no_role('owner', self)
    end
    user.has_role('owner', self)
  end
  
  # Returns true or false, depending on whether the article has any attached media at all
  def has_attached_media?
    self.mediafiles ? true : false
  end
  
  #Comments
  has_many :comments, :dependent => :destroy
  
  state_machine :comment_status, :initial => :enabled , :namespace => 'comments' do
    event :lock do
      transition all => :locked
    end

    event :disable do
      transition all => :disabled
    end

    event :enable do
      transition all => :enabled
    end
  end
  
  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.article do
       xml.tag!( :id, self.id, :type => "integer")
       xml.tag!( :published_at, self.published_at ? self.published_at.to_formatted_s(:long) : "" )
       xml.tag!( :updated_at, self.updated_at.to_formatted_s(:long) )
       xml.tag!( :title, self.title )
       xml.tag!( :subtitle, self.subtitle )
       xml.tag!( :authors_list, self.authors_list )
       xml.tag!( :summary, self.summary )
       xml.tag!( :bodytext, self.bodytext )
       xml.tag!( :word_count, self.word_count )
       
       self.section.nil? ? xml.section("") : xml.section(self.section.name)
       xml.tag!( :tag_list, self.tag_list )
       
       xml.tag!( :account_id, self.account.id, :type => "integer")
       xml.tag!( :account_name, self.account.formal_name.blank? ? self.account.name.capitalize : self.account.formal_name )
       xml.<< self.account.to_xml(:skip_instruct => true)

       # to get the mediafiles' caption, we need to loop over the waxings 
       xml.mediafiles :type => "array" do
         self.waxings.each do |waxing|
           xml.<< waxing.mediafile.to_xml(:skip_instruct => true, :caption => waxing.caption)
         end
       end
       
       xml.categories :type => "array" do
         self.categories.each do |category|
           xml.<< category.to_xml(:skip_instruct => true)
         end
       end
       
       xml.tags :type => "array" do
         self.tags.each do |tag|
           xml.<< tag.to_xml(:skip_instruct => true)
         end
       end       
       
       xml.authors :type => "array" do
         self.authors.each do |author|
           xml.<< author.to_xml(:skip_instruct => true)
         end
       end
       
      if self.is_a?(Entry) && self.blog
        xml.blogs :type => "array" do
          xml.<< self.blog.to_xml(:skip_instruct => true)
        end
      end
       
       xml.issues :type => "array" do
         self.issues.each do |issue|
           xml.<< issue.to_xml(:skip_instruct => true)
         end
       end
                     
     end
  end
  
  
end
