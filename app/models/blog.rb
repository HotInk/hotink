class Blog < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  validates_presence_of :slug
  validates_uniqueness_of :slug, :scope => :account_id
  
  has_many :entries, :through => :postings, :order => "created_at DESC"
  
  has_many :postings
  
  acts_as_authorizable
  
  # Returns an array of contributors
  def contributors
    has_contributors
  end
end
