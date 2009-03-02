class Mediafile < ActiveRecord::Base
  belongs_to :account
  
  has_many :waxings, :dependent => :destroy
  has_many :articles, :through => :waxings
  
  has_many :photocredits
  has_many :authors, :through => :photocredits
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"
  
  accepts_nested_attributes_for :photocredits, :allow_destroy => true
  
  has_attached_file :file,
      :styles => {
        :system_thumb=> ["100>", 'jpg'],
        :thumb  => Proc.new { |instance| instance.settings["thumb"].to_s },
        :small => Proc.new { |instance| instance.settings["small"].to_s },
        :medium => Proc.new { |instance| instance.settings["medium"].to_s },
        :system_default => ["400>", 'jpg'],
        :large => Proc.new { |instance| instance.settings["large"].to_s }
      },
      :convert_options => {
        :all => "-colorspace RGB -strip -quality 80"
      },
      :default_style => :system_default,
      :path => ":rails_root/public/system/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:class/:id_partition/:basename_:style.:extension"
      
  validates_attachment_presence :file
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png']
  
  # Default settings
  # Currently, this needs improvement. Right now these images are processed
  def settings
       default_settings = {
        "thumb" => ['100>', 'jpg'],
        "small" => ['250>', 'jpg'],
        "medium" => ['440>', 'jpg'],
        "large" => ['800>', 'jpg']
        }
    if self.account
      default_settings.merge!(self.account.settings["image"]) if self.account.settings["image"] if self.account.settings
      return default_settings
    else
      return default_settings 
    end
  end
  
  def new_authors_list
    return ""
  end
  
  def new_authors_list=(list)
  end
  
end
