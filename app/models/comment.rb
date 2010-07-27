class Comment < ActiveRecord::Base
  belongs_to :document
  validates_presence_of :document
  
  validates_length_of :name, :within => 2..20
  
  validates_length_of :email, :minimum => 6
  validates_format_of :email, :with => /.*@.*\./  
  
  validates_length_of :body, :within => 5..2000
  
  validates_presence_of :ip_address
  validates_format_of :ip_address, :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/ 
end
