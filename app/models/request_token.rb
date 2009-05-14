class RequestToken < OauthToken
  def authorize!(account)
    return false if authorized?
    self.account = account
    self.authorized_at = Time.now
    self.save
  end
  
  def exchange!
    return false unless authorized?
    RequestToken.transaction do
      access_token = AccessToken.create(:account => account, :client_application => client_application)
      invalidate!
      access_token
    end
  end
end