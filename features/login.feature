Feature: Log in/out links
In order to easily log in and log out
As a user
I want to see the appropriate link

Scenario: A guest user should be redirected to login page
  Given I am not logged in
  And I am on the homepage
  Then I should be redirected to login page

@omniauth_test
Scenario: A logged in user on the search page should see a logout link
  Given I am logged in
  And I am on the homepage
  Then I should see a logout link
  And I should see "Log-out dev123" as the text of the logout link
