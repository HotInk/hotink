
Given /^I have created an account with the name "(.*)"$/ do |name|
  Factory(:account, :name => name)
end