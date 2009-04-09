require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am an authenticated user$/ do 
  user = User.create(:login => "chrisdinn", :email => Factory.next(:email), :password => "james1", :password_confirmation =>  "james1") 
  Then "I log in"
end 
Given /^I am an unauthenticated user$/ do 
  # No code necessary
end

When /^I log in$/ do 
  visit path_to("the login form")
  fill_in "login", :with => "chrisdinn" 
  fill_in "password", :with => "james1" 
  click_button "Login" 
end 

Then /^I should see the login form$/ do 
  response.should contain("Login") 
end


