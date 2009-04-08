module NavigationHelpers
  def path_to(page_name)
    account = Factory(:account)
    
    case page_name
    
    when /the login page/i
      new_user_session_path
    when /the articles index page/i
      account_articles_path( account )
    when /an article page/
      account_article_path(account, Factory(:article, :account_id=>account.id))
      
    
    # Add more page name => path mappings here
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World do |world|
  world.extend NavigationHelpers
  world
end
