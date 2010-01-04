class UserInvitation < Invitation
  belongs_to :account
  validates_presence_of :account

  after_create :set_token, :detect_user

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
      Circulation.deliver_user_invitation(self.account, self)
    end
  
    def send_notification_email
      Circulation.deliver_account_access_notification(self.account, self)
    end

end


