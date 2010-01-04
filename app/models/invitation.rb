class Invitation < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  belongs_to :account
  validates_presence_of :account
  
  validates_presence_of :email 
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+(?:[A-Z]{2}|com|org|net|gov|mil|me|biz|info|mobi|name|aero|jobs|museum)$/i
  
  after_create :set_token, :detect_user
  
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
  
  def detect_user
    user = User.find_by_email(self.email)
    if user
      self.account.promote(user) unless user.has_role('staff', self.account)
      send_notification_email
      self.redeem!
    else
      send_invitation_email
    end
  end
  
  def send_invitation_email
    Circulation.deliver_invitation(self.account, self)
  end
  
  def send_notification_email
    Circulation.deliver_account_access_notification(self.account, self)
  end
  
  def set_token
    self.token = Digest::SHA1.hexdigest("--#{self.email}--#{self.created_at.to_s}--")
    save
  end
  
end
