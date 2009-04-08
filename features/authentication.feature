Feature: User authentication
In order to give account holders control over their data
Registered users should have to
Login before they can access the site

Scenario: Unauthenticated user denied access
	Given I am not a registered user
	Given I am on the login page
	When I log in
	Then I should see "Login"
	
Scenario: Authenticated user granted access
	Given I am a registered user
	Given I am on the login page
	When I log in
	Then I should see "Logged in"
	
Scenario: Articles index protected from public
	Given I am not a registered user
	When I go to the articles index page
	Then I should see "Login"
	
Scenario: Articles index available to registered users
	Given I am a registered user
	When I go to the articles index page
	Then I should see "Articles"

Scenario: Article page protected from public
	Given I am not a registered user
	When I go to an article page
	Then I should see "Login"

Scenario: Article page available to registered users
	Given I am a registered user
	When I go to an article page
	Then I should see "Articles"