# An action is an operation performed on Hot Ink data
class Action

  attr_accessor :name, :content_types
  
  def initialize(options)
    @name = options.delete(:name)
    @content_types = options.delete(:content_types) || []
  end

end
