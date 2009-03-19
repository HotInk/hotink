Feature: Create an account
	In order to add newspapers to the system
	I should be able to
	create a new account object
	
	Scenario: Visit new account page
		When I am on the accounts index page
		When I follow "New account"
		Then I should see "New account"