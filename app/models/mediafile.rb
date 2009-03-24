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
  #TODO: Find out why account validation keeps failing
  #validates_associated :account, :message => "Account must be valid"
  
  accepts_nested_attributes_for :photocredits, :allow_destroy => true
  
  acts_as_taggable_on :tags
  
  has_attached_file :file,
      :path => ":rails_root/public/system/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:class/:id_partition/:basename_:style.:extension"
  
      
  def new_authors_list
    return ""
  end
  
  def new_authors_list=(list)
  end
  
end
