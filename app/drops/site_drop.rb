class SiteDrop < Drop
  
  alias_method :account, :source # for readability

  def url
    account.site_url || "/accounts/#{account.id}"
  end
end
