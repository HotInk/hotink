class Drop < Liquid::Drop
  
  attr_reader :source, :options
  
  def initialize(source = nil, options = {})
    @source = source
    @options = options
  end
  
  def before_method(method)
    "<span class=\"liquid_error\">No data named '#{method}' in #{self.class.name}</span>"
  end

  protected    

  # Source attributes passed in as arguments are made available directly
  def self.liquid_attributes(*args)
    args.each do |method|
      define_liquid_attribute method
    end
  end

  def self.define_liquid_attribute(attr_name)
    self.send(:define_method, attr_name) { source.send(attr_name) }
  end
end