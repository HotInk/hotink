class Image < Mediafile
  
  before_save :save_dimensions 
  
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
  
  attr_accessor :settings
    
  def save_dimensions 
        self.width = Paperclip::Geometry.from_file(file.to_file(:original)).width 
        self.height = Paperclip::Geometry.from_file(file.to_file(:original)).height  
  end
  
  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.mediafile do
       xml.tag!( :title, self.title )
       xml.tag!( :type, self.type || "File" )
       xml.tag!( :date, self.date )
       xml.tag!( :authors_list, self.authors_list )
       xml.url do
         xml.tag!(:original, self.file.url(:original))
         xml.tag!(:thumb, self.file.url(:thumb) )
         xml.tag!(:small, self.file.url(:small))
         xml.tag!(:medium, self.file.url(:medium))
         xml.tag!(:large, self.file.url(:large) )
         xml.tag!(:system_default, self.file.url(:system_default) )
         xml.tag!(:system_thumb, self.file.url(:system_thumb) )
         xml.tag!(:system_icon, self.file.url(:system_icon) )
       end
       xml.tag!( :content_type, self.file_content_type )
       xml.tag!( :id, self.id )
     end
  end
  
end
