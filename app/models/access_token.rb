class AccessToken<OauthToken
  validates_presence_of :account
  before_create :set_authorized_at
  
protected 
  
  def set_authorized_at
    self.authorized_at = Time.now
  end
end