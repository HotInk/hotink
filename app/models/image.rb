class Image < Mediafile
  
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
      :path => ":rails_root/public/system/:class/:account/:id_partition/:basename_:style.:extension",
      :url => "/system/:class/:account/:id_partition/:basename_:style.:extension"
      
  validates_attachment_presence :file
  
  # Default settings
  # Right now these image sizes are processed automatically.
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
  
  
end
