class Circulation < ActionMailer::Base

  default_url_options[:host] = "demo.hotink.net"  

  def account_activation_instructions(user)  
    subject       "Hey, boss! Welcome to Hot Ink."  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_account_activation_url => edit_account_activation_url(user.perishable_token)  
  end  
  
  def user_activation_instructions(user)  
    subject       "Online publishing user activation email"  
    from          "Hot Ink Circulation Dept <circulation@hotink.net>"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_user_activation_url => edit_user_activation_url(user.perishable_token)  
  end
  
end
