class User < ActiveRecord::Base
  belongs_to :account
  
  acts_as_authentic do |c|
      c.crypto_provider = Authlogic::CryptoProviders::BCrypt # Stronger acd more scalable protection with BCrypt
  end
  acts_as_authorized_user
  acts_as_authorizable
  
  # Callbacks
  before_validation :set_empty_login_to_email_username
  
  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end
  
  def deliver_user_activation_instructions!  
    reset_perishable_token!  
    Circulation.deliver_user_activation_instructions(self)  
  end
  
  def deliver_account_activation_instructions!  
    reset_perishable_token!  
    Circulation.deliver_account_activation_instructions(self)  
  end
  
  private
  
  # This method takes care of making sure "blank" login fields still pass validation, without forcing users to select a login.
  # By default, logins are set to the part of the user's email address before the '@' symbol. Of course, users can also set logins to be anything they want.
  def set_empty_login_to_email_username
       self.login = self.email.split('@').first if self.email && self.login.blank?
  end
  
  
end
