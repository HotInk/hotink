class MediafileDrop < Drop
  include ActionView::Helpers::NumberHelper
    
  def initialize(source = nil, options = {})
     super(source)
     @caption = options[:caption]
   end
  
  alias_method :mediafile, :source # for readability
   
  liquid_attributes :id, :title, :date, :description, :authors_list, :image?, :audiofile?, :file?, :height, :width
  
  attr_reader :caption

  def url
    mediafile.url(:original)
  end
  
  def file_size
    number_to_human_size(mediafile.file_size)
  end
  
  def horizontal?
    mediafile.image? && (mediafile.width >= mediafile.height)
  end
  
  def is_horizontal?
    horizontal?
  end
  
  def vertical?
    mediafile.image? && (mediafile.width < mediafile.height)
  end
  
  def is_vertical?
    vertical?
  end
  
  def type
    if mediafile.file?
      "File"
    elsif mediafile.image?
      "Image"
    elsif mediafile.audiofile?
      "Audiofile"
    end
  end
  
  def image_url
    if mediafile.image?
      { "original" => mediafile.url(:original),
        "thumb" => mediafile.url(:thumb),
        "small" => mediafile.url(:small), 
        "medium" => mediafile.url(:medium),
        "large" => mediafile.url(:large), 
        "system_default" => mediafile.url(:system_default), 
        "system_thumb" => mediafile.url(:system_thumb), 
        "system_icon" => mediafile.url(:system_icon) }
    else
      {}
    end
  end
end
