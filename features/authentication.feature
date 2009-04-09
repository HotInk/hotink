Feature: User authentication
In order to restrict access to content
As a Content Owner
I want to respond only to authenticated users

Scenario: Refer unathenticated user to login form
	Given I am an unauthenticated user
	When I load the articles index page
	Then I should see the login form

Scenario Outline: Allow authenticated user to view content
	Given I am an authenticated user
	When I load <page>
	Then I should see <page>
	
	Examples:
		| page 					 	|
		| the articles index page	|
		| a new article form		|
