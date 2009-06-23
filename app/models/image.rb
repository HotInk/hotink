class Image < Mediafile
  
  before_create :save_dimensions 
  
  IMAGE_DEFAULT_SETTINGS = { 
            "thumb" => ['100>', 'jpg'],  
            "small" => ['250>', 'jpg'],
            "medium" => ['440>', 'jpg'],
            "large" => ['800>', 'jpg']
  }
  
  has_attached_file :file,
      :styles => {
        :system_icon => [ "x20>", 'jpg' ],
        :system_thumb => ["100x56>", 'jpg'],
        :thumb  => Proc.new { |instance| instance.settings["thumb"].to_s },
        :small => Proc.new { |instance| instance.settings["small"].to_s },
        :medium => Proc.new { |instance| instance.settings["medium"].to_s },
        :system_default => ["400>", 'jpg'],
        :large => Proc.new { |instance| instance.settings["large"].to_s }
      },
      :convert_options => {
        :all => "-colorspace RGB -strip"
      },
      :default_style => :system_default,
      :path => ":rails_root/public/system/:account/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:account/:class/:id_partition/:basename_:style.:extension"
      
  validates_attachment_presence :file
  
  # Default settings
  # Right now these image sizes are processed automatically.
  def settings
    if self.account
      return IMAGE_DEFAULT_SETTINGS.merge(self.account.settings["image"]) if self.account.settings["image"]
    else
      return IMAGE_DEFAULT_SETTINGS
    end
  end
  
  def save_dimensions 
        self.width = Paperclip::Geometry.from_file(file.to_file(:original)).width 
        self.height = Paperclip::Geometry.from_file(file.to_file(:original)).height 
  end
  
end
