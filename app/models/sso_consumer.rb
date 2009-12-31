class SsoConsumer < ActiveRecord::Base
  validates_uniqueness_of :url, :case_sensitive => false
  
  def self.allowed?(host)
    !find_by_url(host).nil?
  end
end
