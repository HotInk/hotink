class Account < ActiveRecord::Base
  include Pacecar
  
  # Main data models (and STI subclasses)
  has_many :mediafiles, :dependent => :delete_all
  has_many :images
  has_many :audiofiles
  has_many :documents, :dependent => :delete_all
  has_many :articles 
  has_many :entries
  has_many :authors, :dependent => :delete_all
  has_many :categories, :order => "position", :conditions => { :active => true }, :dependent => :delete_all
  has_many :sections, :order => "parent_id, position", :dependent => :delete_all
  has_many :blogs, :dependent => :delete_all
  has_many :issues, :dependent => :delete_all, :order => "date desc"
  has_many :email_templates
  has_many :lists
  has_many :pages
  
  has_one :membership
  has_many :user_invitations
  has_many :active_user_invitations, :class_name => 'UserInvitation', :conditions => { :redeemed => false }
  
  has_recent_records :articles
  named_scope :by_most_recently_published,lambda { {:joins => 'INNER JOIN documents ON documents.account_id=accounts.id', :group => 'accounts.id', :order => 'documents.updated_at', :conditions => ["documents.status = 'Published' AND documents.published_at <= ?", Time.now.utc]} }
  
  # Authentication
  has_many :users, :dependent => :delete_all
  
  # Join models
  has_many :authorships, :dependent => :delete_all
  has_many :photocredits, :dependent => :delete_all
  has_many :printings, :dependent => :delete_all
  has_many :sortings, :dependent => :delete_all
  has_many :waxings, :dependent => :delete_all
  
  # Special category functionality 
  has_many :main_categories, :class_name => "Category", :order => "position", :conditions => {:parent_id => nil } # An account's top-level categories
  accepts_nested_attributes_for :categories
  
  acts_as_authorizable
  acts_as_tagger

  validates_presence_of :time_zone, :message => "Account must indicate its preferred time zone."
  validates_presence_of :name, :message => "Account must have a name"
  validates_uniqueness_of :name, :message => "Account name must be unique"
  
  serialize :settings
  serialize :lead_article_ids
  
  has_many  :designs
  belongs_to :current_design, :class_name => "Design", :foreign_key => :current_design_id
  
  # Settings defaults
  IMAGE_DEFAULT_SETTINGS = { 
            "thumb" => ['100>', 'jpg'],  
            "small" => ['250>', 'jpg'],
            "medium" => ['440>', 'jpg'],
            "large" => ['800>', 'jpg']
  }
  
  before_create :set_default_settings
    
  def settings
    read_attribute(:settings)
  end
  
  def image_settings=(new_settings)
    account_settings = read_attribute(:settings)
    account_settings["image"] = {} if settings["image"].nil?
    raise ArgumentError unless new_settings.is_a? Hash
    new_settings.each do |key, value|
      
      if value[:height].blank?
        new_height = ""
      else
        new_height="x" + value[:height]
      end
      
      if value[:width].blank?
        new_width = ""
      else
        new_width= value[:width]
      end
      
      account_settings["image"].update( key => [new_width + new_height + ">", "jpg"]) unless new_height.blank?&&new_width.blank?
    end
    write_attribute(:settings, account_settings)
  end
  
  # Human readable list of account manager
  def managers_list
    managers = self.has_managers
     case managers.length
     when 0
       return nil
     when 1
       return "#{managers.first.name} <#{managers.first.email}>"
     when 2
       return "#{managers.first.name} <#{managers.first.email}>" + " and " + "#{managers.second.name} <#{managers.second.email}>"
     else
      list = String.new
      (0..(managers.length - 3)).each{ |i| list += "#{managers[i].name} <#{managers[i].email}>, " }
      list += "#{managers[managers.length-2].name} <#{managers[managers.length-2].email}>" + " and " + "#{managers[managers.length-1].name} <#{managers[managers.length-1].email}>" # last two managers get special formatting
      return list
    end         
  end

  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.account do
       xml.tag!( :id, self.id )       
       xml.tag!( :name, self.name)
       xml.tag!( :time_zone, self.time_zone)
     end
  end
  
  # Account user management
  def promote(user)
    if user.has_role?('staff', self)
      if user.has_role?('editor', self)
          user.has_no_role('editor', self)
          user.has_role('manager', self)
      else
        user.has_role('editor', self)
      end
    else
      user.has_role('staff', self)
    end
  end
  
  def demote(user)
    if user.has_role?('manager', self)
      user.has_no_role('manager', self)
      user.has_role('editor', self)
    elsif user.has_role?('editor', self)
      user.has_no_role('editor', self)
    elsif user.has_role?('staff', self)
      user.has_no_role('staff', self)
    end
  end
    
  # Network
  has_many :network_memberships, :class_name => "Membership", :foreign_key => :network_owner_id 
    
  private
  
  def set_default_settings
    write_attribute(:settings, { "image" => IMAGE_DEFAULT_SETTINGS } )
  end
end
