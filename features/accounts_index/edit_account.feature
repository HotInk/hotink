Feature: Edit an account
	In order to keep account data up to date
	I should should be able to
	edit the details of an account
	
	Scenario: Click account name to edit
		Given I have created an account with the name "onlinejournal"
		Given I am on the accounts index page
		When I follow "onlinejournal"
		Then I should see "Editing account"
