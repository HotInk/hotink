class Comment < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  
  belongs_to :document
  validates_presence_of :document
  
  validates_length_of :name, :within => 2..20
  
  validates_length_of :email, :minimum => 6
  validates_format_of :email, :with => /.*@.*\./  
  
  validates_length_of :body, :within => 5..10000
  
  validates_presence_of :ip_address
  validates_format_of :ip_address, :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/ 

  define_index do
    indexes name
    indexes email
    indexes body
    indexes document.title

    has account_id
    
    set_property :delta => :delayed
  end
  
  def word_count
    body.nil? ? 0 : body.scan(/\w+/).size
  end

end
