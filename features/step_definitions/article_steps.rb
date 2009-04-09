
When /I load the articles index page/i do
  visit account_articles_path(Factory(:account))
end

When /I load a new article form/ do
  visit new_account_article_path(Factory(:account))
end

Then /^I should see the articles index page$/ do 
  response.should contain("Articles") 
  response.should contain("Select all")  #This better identifies the articles index page 
end

Then /^I should see a new article form$/ do
  response.should contain("Edit article")
end
