class Image < Attachment
  
  has_attached_file :file,
      :styles => {
        :system_thumb=> ["220>", 'jpg'],
        :thumb  => Proc.new { |instance| instance.settings["thumb"].to_s },
        :small => Proc.new { |instance| instance.settings["small"].to_s },
        :medium => Proc.new { |instance| instance.settings["medium"].to_s },
        :system_default => ["600x600>", 'jpg'],
        :large => Proc.new { |instance| instance.settings["large"].to_s }
      },
      :convert_options => {
        :all => "-colorspace RGB -strip -quality 80"
      },
      :default_style => :system_default,
      :path => ":rails_root/public/system/:class/:account/:id_partition/:basename_:style.:extension",
      :url => "/system/:class/:account/:id_partition/:basename_:style.:extension"
      
  validates_attachment_presence :file
  validates_attachment_content_type :file, :content_type => "image/jpeg"
  
  #Default settings
  def settings 
    default_settings = {
    "thumb" => ['100>', 'jpg'],
    "small" => ['250>', 'jpg'],
    "medium" => ['440>', 'jpg'],
    "large" => ['800>', 'jpg']
    }
    default_settings.merge!(self.account.settings["image"]) if self.account.settings["image"] if self.account.settings
    default_settings
  end
  
  
end
