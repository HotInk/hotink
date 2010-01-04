class AccountInvitation < Invitation
  named_scope :active, :conditions => { :redeemed => :false }
  
  after_create :set_token, :send_invitation_email
  
  private

  def send_invitation_email
    Circulation.deliver_account_invitation(self)
  end

end