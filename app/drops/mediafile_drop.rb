class MediafileDrop < Drop
  liquid_attributes :url
  
  attr_reader :caption
  
  def initialize(source = nil, options = {})
     super(source)
     @caption = options[:caption]
   end
end
