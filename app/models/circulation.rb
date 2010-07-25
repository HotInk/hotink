class Circulation < ActionMailer::Base

  default_url_options[:host] = "hotink.theorem.ca"  
  
  def password_reset_instructions(user)  
    subject       "Hot Ink Password Reset Instructions"  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
  
  def user_invitation(account, invite)
    subject       "You've been invited to use Hot Ink"  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    invite.email  
    sent_on       Time.now  
    body          :edit_invitation_url => edit_user_invitation_url(invite)  
  end
  
  def account_invitation(invite)
    subject       "Hey, boss! Welcome to Hot Ink."  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    invite.email  
    sent_on       Time.now  
    body          :edit_invitation_url => edit_invitation_url(invite)  
  end
  
  def account_access_notification(account, invite)
    subject       "You've been given access to another Hot Ink account"  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    invite.email  
    sent_on       Time.now  
    body          :account_name => (account.formal_name || account.name), :user_name => invite.user.name, :user_email => invite.user.email, :account_url => dashboard_url
  end
end
