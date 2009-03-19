Feature: Update an account
	In order to keep account data up to date
	I should should be able to
	update the details of an account
	
	Scenario: Update account details
		Given I have created an account with the name "update_test"
		When I am on the accounts index page
		When I follow "update_test"
			And I fill in "update_test_success" for "Name"
			And I press "Update"
		Then I should see "update_test_success"
		