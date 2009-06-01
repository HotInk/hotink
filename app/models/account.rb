class Account < ActiveRecord::Base
  
  # Main data models (and STI subclasses)
  has_many :mediafiles, :dependent => :delete_all
  has_many :images
  has_many :audiofiles
  has_many :documents, :dependent => :delete_all
  has_many :articles 
  has_many :entries
  has_many :authors, :dependent => :delete_all
  has_many :categories, :order => "position", :dependent => :delete_all
  has_many :sections, :order => "parent_id, position", :dependent => :delete_all
  has_many :blogs, :dependent => :delete_all
  has_many :issues, :dependent => :delete_all, :order => "date"
  
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
  
  #Implement acts_as
  acts_as_authorizable
  acts_as_tagger

  validates_presence_of :time_zone, :message => "Account must indicate its preferred time zone."
  validates_presence_of :name, :message => "Account must have a name"
  validates_uniqueness_of :name, :message => "Account name must be unique"
  
  serialize :settings
  
  
  
  # Human readable list of account manager
  def managers_list
    managers = self.has_managers
     case managers.length
     when 0
       return nil
     when 1
       return "#{managers.first.name} <#{managers.first.email}>"
     when 2
       return "#{managers.first.name} <#{managers.first.email}>" + " and " + "#{managers.second.login} <#{managers.second.email}>"
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
  
end
