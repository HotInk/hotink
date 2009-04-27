class User < ActiveRecord::Base
  belongs_to :account
  
  acts_as_authentic do |c|
      c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  
  acts_as_authorized_user
  acts_as_authorizable
  
end
