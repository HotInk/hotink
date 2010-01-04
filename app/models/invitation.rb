class Invitation < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  validates_presence_of :email 
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+(?:[A-Z]{2}|com|org|net|gov|mil|me|biz|info|mobi|name|aero|jobs|museum)$/i
  
  after_create :set_token
  
  def redeemed?
    redeemed
  end
  
  def redeem!
    unless redeemed?
      update_attribute('redeemed', true)
    else
      false
    end
  end
  
  def to_param
    self.token
  end
  
  private
  
  def set_token
    self.token = Digest::SHA1.hexdigest("--#{self.email}--#{self.created_at.to_s}--")
    save
  end
  
end
