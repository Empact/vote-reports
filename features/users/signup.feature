Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up
  
    Scenario: User signs up with invalid data
      When I go to the signup page
      And I fill in "Username" with "nobody"
      And I fill in "Email" with "invalidemail"
      And I fill in "Password" with "password"
      And I press "Sign up"
      Then I should see error messages
      
    Scenario: User signs up with valid data
      When I go to the signup page
      And I fill in "Username" with "James"
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Password confirmation" with "password"
      And I press "Sign up"
      Then I should see "Thanks for signing up. Welcome to VoteReports."