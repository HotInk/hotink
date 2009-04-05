module NavigationHelpers
  def path_to(page_name)
    case page_name
          
    # Add more page name => path mappings here
    when /the accounts index page/
      accounts_path
    
    when /the article edit page/
      article = Factory(:article)
      edit_account_article_path(article.account, article )
      
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World do |world|
  world.extend NavigationHelpers
  world
end
