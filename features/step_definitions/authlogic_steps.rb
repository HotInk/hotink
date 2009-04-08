require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am a registered user$/ do 
  User.create(:login => "chrisdinn", :email => Factory.next(:email), :password => "james1", :password_confirmation =>  "james1") 
end 
Given /^I am not a registered user$/ do 
  # No code necessary
end

When /^I log in$/ do 
  fill_in "login", :with => "chrisdinn" 
  fill_in "password", :with => "james1" 
  click_button "Login" 
end 

Then /^I should see my account page$/ do 
  #save_and_open_page 
  response.should contain('james') 
end