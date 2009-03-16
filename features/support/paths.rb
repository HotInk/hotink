module NavigationHelpers
  def path_to(page_name)
    case page_name
          
    # Add more page name => path mappings here
    when /the accounts index page/
      "http://localhost:3001/accounts"
      
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World do |world|
  world.extend NavigationHelpers
  world
end
