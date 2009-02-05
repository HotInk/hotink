class Account < ActiveRecord::Base
  has_many :articles, :dependent => :delete_all
  has_many :attachments, :dependent => :delete_all
  has_many :authors, :dependent => :delete_all
  has_many :authorships, :dependent => :delete_all
  has_many :categories, :dependent => :delete_all
  has_many :sections, :dependent => :delete_all
  has_many :issues, :dependent => :delete_all, :order => "date"
  has_many :photocredits, :dependent => :delete_all
  has_many :printings, :dependent => :delete_all
  has_many :sortings, :dependent => :delete_all
  has_many :tags, :dependent => :delete_all
  has_many :taggings, :dependent => :delete_all
  has_many :waxings, :dependent => :delete_all
end
