class Blog < ActiveRecord::Base
  include BlogsHelper

  belongs_to :account
  validates_presence_of :account
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  validates_uniqueness_of :slug, :scope => :account_id
  validates_format_of :slug, :with => /^[-a-z0-9]+$/, :message => "should consist of letters, numbers and dashes only"
  before_validation :autoset_slug
  
  has_attached_file :image,
      :styles => { :thumb => "100x100>", :small => "360>", :large => "580>" },
      :convert_options => { :all => "-colorspace RGB -strip"},
      :path => ":rails_root/public/system/:account/:class/:id/:basename_:style.:extension",
      :url => "/system/:account/:class/:id/:basename_:style.:extension"
      
  validates_attachment_content_type :image, :content_type => ['image/png', 'image/jpeg', 'image/gif']

  has_many :entries, :order => "created_at DESC"
  
  named_scope :active, :conditions => {:status => true}
  named_scope :inactive, :conditions => {:status => false}  
  
  acts_as_authorizable

  # Returns an array of contributors
  def contributors
    has_contributors
  end

  def active?
    read_attribute :status
  end
  
  def activate
    update_attribute(:status, true)
  end
  
  def deactivate
    update_attribute(:status, false)
  end

  private
  
  def autoset_slug
    update_attribute(:slug, generate_slug(self.title)) if self.slug.blank?
  end
end
