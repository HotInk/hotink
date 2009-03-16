Feature: List accounts
	In order to understand which accounts exist
	Users should be able to
	list accounts that exist
	
	Scenario: List one account
		Given I have created an account with the name "root"
		When I am on the accounts index page
		Then I should see "root"
		 
	Scenario: List multiple accounts
		# "root" already exists.
		Given accounts named "boot" and "fruit" exist
		When I am on the accounts index page
		Then I should see "root"
		Then I should see "boot"
		Then I should see "fruit"
		
