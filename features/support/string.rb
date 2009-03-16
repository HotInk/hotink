# Examples:
# "'Foo', 'Bar', and 'Jar'".extract_list # => ["Foo", "Bar", "Jar"]
# '"Dog", "Cat"'.extract_list # => ["Dog", "Cat"]
class String
  def extract_list
    self.scan((/['"](.*?)["']/)).flatten
  end                                                                                                                                                                                                        
end
