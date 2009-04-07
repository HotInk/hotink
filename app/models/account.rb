class Account < ActiveRecord::Base
  
  # Main data models (and subclasses)
  has_many :mediafiles, :dependent => :delete_all
  has_many :images
  has_many :audiofiles
  has_many :articles, :dependent => :delete_all  
  has_many :authors, :dependent => :delete_all
  has_many :categories, :order => "position", :dependent => :delete_all
  has_many :sections, :dependent => :delete_all
  has_many :issues, :dependent => :delete_all, :order => "date"
  
  # Authentication
  has_many :users, :dependent => :delete_all
  
  # Join models
  has_many :authorships, :dependent => :delete_all
  has_many :photocredits, :dependent => :delete_all
  has_many :printings, :dependent => :delete_all
  has_many :sortings, :dependent => :delete_all
  has_many :waxings, :dependent => :delete_all
  
  accepts_nested_attributes_for :categories
  
  #Implement acts_as_taggable_on
  acts_as_tagger

  validates_presence_of :time_zone, :message => "Account must indicate its preferred time zone."
  validates_presence_of :name, :message => "Account must have a name"
  validates_uniqueness_of :name, :message => "Account name must be unique"
  
  def settings
    settings_from_db = read_attribute('settings')
    if settings_from_db
      YAML::load( read_attribute('settings'))
    else
      {}
    end
  end
  
end
