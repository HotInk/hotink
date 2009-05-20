class User < ActiveRecord::Base
  belongs_to :account
  
  # OAuth API application support
  has_many :client_applications
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]
  
  
  serialize :preferences
  
  # A user's account is it's ticket to access during activation
  # To prevent users from sneaking in a new account during activation, we protect it.
  # After activation, it's not a big deal, since roles handle allowing or disallowing 
  # access to resources. You can pretend to be from any account you want, if you don't
  # have teh proper role, you won't get access.
  attr_protected :account_id
  
  acts_as_authentic do |c|
      c.crypto_provider = Authlogic::CryptoProviders::BCrypt # Stronger and more scalable protection with BCrypt
      c.ignore_blank_passwords = false # To catch activations, we want the system to complain if a user leaves the password/confirmation fields blank
  end
  acts_as_authorized_user
  acts_as_authorizable
  
  # Callbacks
  before_create :set_empty_login_to_email_username
  
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :email, :message => "Email must be unique"
  
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
  
  # When users are invited to Hot Ink, they're saved with a random password, but emailed a single_access_token. They don't know the 
  # password, so they have to "activate" in order to set their own. We call users in this pre-activation stage "inactive."
  def save_as_inactive(validate = true)
    reset_single_access_token
    reset_password
    save(validate)
  end
  
  def save_as_inactive!(validate = true)
    reset_single_access_token
    reset_password
    save!(validate)
  end
  
  private
  
  # This method takes care of making sure "blank" login fields still pass validation, without forcing users to select a login.
  # By default, logins are set to the part of the user's email address before the '@' symbol. Of course, users can also set logins to be anything they want.
  def set_empty_login_to_email_username
    if self.email && self.login.blank?
       email_username = self.email.split('@').first
       temp_login, num = email_username, 1
       while User.find_by_login(temp_login) do
         temp_login = email_username + num.to_s
         num = num + 1
       end
       self.login = temp_login
    end
  end
  
  
end
